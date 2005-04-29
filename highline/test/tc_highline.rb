#!/usr/local/bin/ruby -w

# tc_highline.rb
#
#  Created by James Edward Gray II on 2005-04-26.
#  Copyright 2005 Gray Productions. All rights reserved.

$test_lib_dir ||= File.join(File.dirname(__FILE__), "..", "lib")
$:.unshift($test_lib_dir) unless $:.include?($test_lib_dir)

require "test/unit"

require "highline"
require "stringio"

class TestHighLine < Test::Unit::TestCase
	def setup
		@input    = StringIO.new
		@output   = StringIO.new
		@terminal = HighLine.new(@input, @output)	
	end
	
	def test_agree
		@input << "y\nyes\nYES\nHell no!\nNo\n"
		@input.rewind

		assert_equal(true, @terminal.agree("Yes or no?  "))
		assert_equal(true, @terminal.agree("Yes or no?  "))
		assert_equal(true, @terminal.agree("Yes or no?  "))
		assert_equal(false, @terminal.agree("Yes or no?  "))
	end
	
	def test_ask
		name = "James Edward Gray II"
		@input << name << "\n"
		@input.rewind

		assert_equal(name, @terminal.ask("What is your name?  "))
	end
	
	def test_defaults
		@input << "\nNo Comment\n"
		@input.rewind

		answer = @terminal.ask("Are you sexually active?  ") do |q|
			q.validate = /\Ay(?:es)?|no?|no comment\Z/i
		end
		assert_equal("No Comment", answer)

		@input.truncate(@input.rewind)
		@input << "\nYes\n"
		@input.rewind
		@output.truncate(@output.rewind)

		answer = @terminal.ask("Are you sexually active?  ") do |q|
			q.default  = "No Comment"
			q.validate = /\Ay(?:es)?|no?|no comment\Z/i
		end
		assert_equal("No Comment", answer)
		assert_equal( "Are you sexually active?  |No Comment|  ",
		              @output.string )
	end
	
	def test_empty
		@input << "\n"
		@input.rewind

		answer = @terminal.ask("") do |q|
			q.default  = "yes"
			q.validate = /\Ay(?:es)?|no?\Z/i
		end
		assert_equal("yes", answer)
	end
	
	def test_range_requirements
		@input << "112\n-541\n28\n"
		@input.rewind

		answer = @terminal.ask("Tell me your age.", Integer) do |q|
			q.in = 0..105
		end
		assert_equal(28, answer)
		assert_equal( "Tell me your age.\n" +
		              "Your answer isn't within the expected range " +
		              "(included in 0..105).\n" +
		              "?  " +
		              "Your answer isn't within the expected range " +
		              "(included in 0..105).\n" +
		              "?  ", @output.string )

		@input.truncate(@input.rewind)
		@input << "1\n-541\n28\n"
		@input.rewind
		@output.truncate(@output.rewind)

		answer = @terminal.ask("Tell me your age.", Integer) do |q|
			q.above = 3
		end
		assert_equal(28, answer)
		assert_equal( "Tell me your age.\n" +
		              "Your answer isn't within the expected range " +
		              "(above 3).\n" +
		              "?  " +
		              "Your answer isn't within the expected range " +
		              "(above 3).\n" +
		              "?  ", @output.string )

		@input.truncate(@input.rewind)
		@input << "1\n28\n-541\n"
		@input.rewind
		@output.truncate(@output.rewind)

		answer = @terminal.ask("Lowest numer you can think of?", Integer) do |q|
			q.below = 0
		end
		assert_equal(-541, answer)
		assert_equal( "Lowest numer you can think of?\n" +
		              "Your answer isn't within the expected range " +
		              "(below 0).\n" +
		              "?  " +
		              "Your answer isn't within the expected range " +
		              "(below 0).\n" +
		              "?  ", @output.string )

		@input.truncate(@input.rewind)
		@input << "1\n-541\n6\n"
		@input.rewind
		@output.truncate(@output.rewind)

		answer = @terminal.ask("Enter a low even number:  ", Integer) do |q|
			q.above = 0
			q.below = 10
			q.in    = [2, 4, 6, 8]
		end
		assert_equal(6, answer)
		assert_equal( "Enter a low even number:  " +
		              "Your answer isn't within the expected range " +
		              "(above 0, below 10, and included in [2, 4, 6, 8]).\n" +
		              "?  " +
		              "Your answer isn't within the expected range " +
		              "(above 0, below 10, and included in [2, 4, 6, 8]).\n" +
		              "?  ", @output.string )
	end
	
	def test_reask
		number = 61676
		@input << "Junk!\n" << number << "\n"
		@input.rewind

		answer = @terminal.ask("Favorite number?  ", Integer)
		assert_kind_of(Integer, number)
		assert_instance_of(Fixnum, number)
		assert_equal(number, answer)
		assert_equal( "Favorite number?  " +
		              "You must enter a valid Integer.\n" +
		              "?  ", @output.string )

		@input.rewind
		@output.truncate(@output.rewind)

		answer = @terminal.ask("Favorite number?  ", Integer) do |q|
			q.responses[:ask_on_error] = :question
			q.responses[:invalid_type] = "Not a valid number!"
		end
		assert_kind_of(Integer, number)
		assert_instance_of(Fixnum, number)
		assert_equal(number, answer)
		assert_equal( "Favorite number?  " +
		              "Not a valid number!\n" +
		              "Favorite number?  ", @output.string )

		@input.truncate(@input.rewind)
		@input << "gen\ngene\n"
		@input.rewind
		@output.truncate(@output.rewind)

		answer = @terminal.ask("Select a mode:  ", [:generate, :gentle])
		assert_instance_of(Symbol, answer)
		assert_equal(:generate, answer)
		assert_equal("Select a mode:  " +
		             "Ambiguous choice.  " +
		             "Please choose one of [:generate, :gentle].\n" +
		             "?  ", @output.string)
	end
	
	def test_say
		@terminal.say("This will have a newline.")
		assert_equal("This will have a newline.\n", @output.string)

		@output.truncate(@output.rewind)

		@terminal.say("This will also have one newline.\n")
		assert_equal("This will also have one newline.\n", @output.string)

		@output.truncate(@output.rewind)

		@terminal.say("This will not have a newline.  ")
		assert_equal("This will not have a newline.  ", @output.string)
	end

	def test_type_conversion
		number = 61676
		@input << number << "\n"
		@input.rewind

		answer = @terminal.ask("Favorite number?  ", Integer)
		assert_kind_of(Integer, answer)
		assert_instance_of(Fixnum, answer)
		assert_equal(number, answer)
		
		@input.truncate(@input.rewind)
		number = 1_000_000_000_000_000_000_000_000_000_000
		@input << number << "\n"
		@input.rewind

		answer = @terminal.ask("Favorite number?  ", Integer)
		assert_kind_of(Integer, answer)
		assert_instance_of(Bignum, answer)
		assert_equal(number, answer)

		@input.truncate(@input.rewind)
		number = 10.5002
		@input << number << "\n"
		@input.rewind

		answer = @terminal.ask( "Favorite number?  ",
								lambda { |n| n.to_f.abs.round } )
		assert_kind_of(Integer, answer)
		assert_instance_of(Fixnum, answer)
		assert_equal(11, answer)

		@input.truncate(@input.rewind)
		animal = :dog
		@input << animal << "\n"
		@input.rewind

		answer = @terminal.ask("Favorite animal?  ", Symbol)
		assert_instance_of(Symbol, answer)
		assert_equal(animal, answer)

		@input.truncate(@input.rewind)
		@input << "6/16/76\n"
		@input.rewind

		answer = @terminal.ask("Enter your birthday.", Date)
		assert_instance_of(Date, answer)
		assert_equal(16, answer.day)
		assert_equal(6, answer.month)
		assert_equal(76, answer.year)

		@input.truncate(@input.rewind)
		pattern = "^yes|no$"
		@input << pattern << "\n"
		@input.rewind

		answer = @terminal.ask("Give me a pattern to match with:  ", Regexp)
		assert_instance_of(Regexp, answer)
		assert_equal(/#{pattern}/, answer)

		@input.truncate(@input.rewind)
		@input << "gen\n"
		@input.rewind

		answer = @terminal.ask("Select a mode:  ", [:generate, :run])
		assert_instance_of(Symbol, answer)
		assert_equal(:generate, answer)
	end
	
	def test_validation
		@input << "system 'rm -rf /'\n105\n0b101_001\n"
		@input.rewind

		answer = @terminal.ask("Enter a binary number:  ") do |q|
			q.validate = /\A(?:0b)?[01_]+\Z/
		end
		assert_equal("0b101_001", answer)
		assert_equal( "Enter a binary number:  " +
		              "Your answer isn't valid " +
		              "(must match /\\A(?:0b)?[01_]+\\Z/).\n" +
		              "?  " +
		              "Your answer isn't valid " +
		              "(must match /\\A(?:0b)?[01_]+\\Z/).\n" +
		              "?  ", @output.string )

		@input.truncate(@input.rewind)
		@input << "Gray II, James Edward\n" +
		          "Gray, Dana Ann Leslie\n" +
		          "Gray, James Edward\n"
		@input.rewind

		answer = @terminal.ask("Your name?  ") do |q|
			q.validate = lambda do |name|
				names = name.split(/,\s*/)
				return false unless names.size == 2
				return false if names.first =~ /\s/
				names.last.split.size == 2
			end
		end
		assert_equal("Gray, James Edward", answer)
	end
end
