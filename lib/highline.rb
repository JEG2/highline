#!/usr/local/bin/ruby -w

# highline.rb
#
#  Created by James Edward Gray II on 2005-04-26.
#  Copyright 2005 Gray Productions. All rights reserved.
#
# See HighLine for documentation.

require "highline/question"
require "erb"

#
# A HighLine object is a "high-level line oriented" shell over an input and an 
# output stream.  HighLine simplifies common console interaction, effectively
# replacing puts() and gets().  User code can simply specify the question to ask
# and any details about user interaction, then leave the rest of the work to
# HighLine.  When HighLine.ask() returns, you'll have to answer you requested,
# even if HighLine had to ask many times, validate results, perform range
# checking, convert types, etc.
#
class HighLine
	# An internal HighLine error.  User code does not need to trap this.
	class QuestionError < StandardError
		# do nothing, just creating a unique error type
	end

	#
	# Embed in a String to clear all previous ANSI sequences.  This *MUST* be 
	# done before the program exits!
	# 
	CLEAR      = "\e[0m"
	# An alias for CLEAR.
	RESET      = CLEAR
	# The start of an ANSI bold sequence.
	BOLD       = "\e[1m"
	# The start of an ANSI dark sequence.  (Terminal support uncommon.)
	DARK       = "\e[2m"
	# The start of an ANSI underline sequence.
	UNDERLINE  = "\e[4m"
	# An alias for UNDERLINE.
	UNDERSCORE = UNDERLINE
	# The start of an ANSI blink sequence.  (Terminal support uncommon.)
	BLINK      = "\e[5m"
	# The start of an ANSI reverse sequence.
	REVERSE    = "\e[7m"
	# The start of an ANSI concealed sequence.  (Terminal support uncommon.)
	CONCEALED  = "\e[8m"

	# Set the terminal's foreground ANSI color to black.
	BLACK      = "\e[30m"
	# Set the terminal's foreground ANSI color to red.
	RED        = "\e[31m"
	# Set the terminal's foreground ANSI color to green.
	GREEN      = "\e[32m"
	# Set the terminal's foreground ANSI color to yellow.
	YELLOW     = "\e[33m"
	# Set the terminal's foreground ANSI color to blue.
	BLUE       = "\e[34m"
	# Set the terminal's foreground ANSI color to magenta.
	MAGENTA    = "\e[35m"
	# Set the terminal's foreground ANSI color to cyan.
	CYAN       = "\e[36m"
	# Set the terminal's foreground ANSI color to white.
	WHITE      = "\e[37m"

	# Set the terminal's background ANSI color to black.
	ON_BLACK   = "\e[40m"
	# Set the terminal's background ANSI color to red.
	ON_RED     = "\e[41m"
	# Set the terminal's background ANSI color to green.
	ON_GREEN   = "\e[42m"
	# Set the terminal's background ANSI color to yellow.
	ON_YELLOW  = "\e[43m"
	# Set the terminal's background ANSI color to blue.
	ON_BLUE    = "\e[44m"
	# Set the terminal's background ANSI color to magenta.
	ON_MAGENTA = "\e[45m"
	# Set the terminal's background ANSI color to cyan.
	ON_CYAN    = "\e[46m"
	# Set the terminal's background ANSI color to white.
	ON_WHITE   = "\e[47m"

	#
	# Create an instance of HighLine, connected to the streams _input_
	# and _output_.
	#
	def initialize( input = $stdin, output = $stdout )
		@input  = input
		@output = output
	end
	
	#
	# A shortcut to HighLine.ask() a question that only accepts "yes" or "no"
	# answers ("y" and "n" are allowed) and returns +true+ or +false+
	# (+true+ for "yes").
	#
	def agree( yes_or_no_question )
		ask(yes_or_no_question, lambda { |yn| yn.downcase[0] == ?y}) do |q|
			q.validate                 = /\Ay(?:es)?|no?\Z/i
			q.responses[:not_valid]    = 'Please enter "yes" or "no".'
			q.responses[:ask_on_error] = :question
		end
	end
	
	#
	# This method is the primary interface for user input.  Just provide a
	# _question_ to ask the user, the _answer_type_ you want returned, and
	# optionally a code block setting up details of how you want the question
	# handled.  See HighLine.say() for details on the format of _question_, and
	# HighLine::Question for more information about _answer_type_ and what's
	# valid in the code block.
	#
	def ask( question, answer_type = String, &details ) # :yields: question
		question = Question.new(question, answer_type, &details)
		
		say(question)
		begin
			answer = question.answer_or_default(get_response)
			unless question.valid_answer?(answer)
				explain_error(question, :not_valid)
				raise QuestionError
			end
			
			answer = question.convert(answer)
			
			if question.in_range?(answer)
				answer
			else
				explain_error(question, :not_in_range)
				raise QuestionError
			end
		rescue QuestionError
			retry
		rescue ArgumentError
			explain_error(question, :invalid_type)
			retry
		rescue NameError
			raise if $!.is_a?(NoMethodError)
			explain_error(question, :ambiguous_completion)
			retry
		end
	end

	#
	# This method provides easy access to ANSI color sequences, without user
	# needing to remember to CLEAR at the end of each sequence.  Just pass the
	# _string_ to color, followed by a list of _colors_ you would like it to be
	# affected by.  The _colors_ can be HighLine class constants, or symbols 
	# (:blue for BLUE, for example).  A CLEAR will automatically be embedded to
	# the end of the returned String.
	#
	def color( string, *colors )
		colors.map! do |c|
			if c.is_a?(Symbol)
				self.class.const_get(c.to_s.upcase)
			else
				c
			end
		end
		"#{colors.join}#{string}#{CLEAR}"
	end
	
	#
	# The basic output method for HighLine objects.  If the provided _statement_
	# ends with a space or tab character, a newline will not be appended (output
	# will be flush()ed).  All other cases are passed straight to Kernel.puts().
	#
	# The _statement_ parameter is processed as an ERb template, supporting
	# embedded Ruby code.  The template is evaluated with a binding inside 
	# the HighLine instance, providing easy access to the ANSI color constants
	# and the HighLine.color() method.
	#
	def say( statement )
		statement = statement.to_s
		return unless statement.length > 0
		
		template  = ERB.new(statement, nil, "%")
		statement = template.result(binding)
		
		if statement[-1, 1] == " " or statement[-1, 1] == "\t"
			@output.print(statement)
			@output.flush	
		else
			@output.puts(statement)
		end
	end
	
	private
	
	#
	# A helper method for sending the output stream and error and repeat
	# of the question.
	#
	def explain_error( question, error )
		say(question.responses[error])
		if question.responses[:ask_on_error] == :question
			say(question)
		elsif question.responses[:ask_on_error]
			say(question.responses[:ask_on_error])
		end
	end
	
	#
	# Read a line of input from the input stream, chomp()ing any newline
	# characters.
	#
	def get_response(  )
		@input.gets.chomp
	end
end
