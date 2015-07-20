# coding: utf-8

#--
# highline.rb
#
#  Created by James Edward Gray II on 2005-04-26.
#  Copyright 2005 Gray Productions. All rights reserved.
#
# See HighLine for documentation.
#
# This is Free Software.  See LICENSE and COPYING for details.

require "erb"
require "optparse"
require "stringio"
require "abbrev"
require "highline/terminal"
require "highline/question"
require "highline/menu"
require "highline/color_scheme"
require "highline/style"
require "highline/version"
require "highline/statement"
require "highline/list_renderer"
require "highline/builtin_styles"

#
# A HighLine object is a "high-level line oriented" shell over an input and an
# output stream.  HighLine simplifies common console interaction, effectively
# replacing puts() and gets().  User code can simply specify the question to ask
# and any details about user interaction, then leave the rest of the work to
# HighLine.  When HighLine.ask() returns, you'll have the answer you requested,
# even if HighLine had to ask many times, validate results, perform range
# checking, convert types, etc.
#
class HighLine
  include BuiltinStyles

  # An internal HighLine error.  User code does not need to trap this.
  class QuestionError < StandardError
    # do nothing, just creating a unique error type
  end

  class NotValidQuestionError < QuestionError
    # do nothing, just creating a unique error type
  end

  class NotInRangeQuestionError < QuestionError
    # do nothing, just creating a unique error type
  end

  class NoConfirmationQuestionError < QuestionError
    # do nothing, just creating a unique error type
  end

  # The setting used to disable color output.
  @use_color = true

  # Pass +false+ to _setting_ to turn off HighLine's color escapes.
  def self.use_color=( setting )
    @use_color = setting
  end

  # Returns true if HighLine is currently using color escapes.
  def self.use_color?
    @use_color
  end

  # For checking if the current version of HighLine supports RGB colors
  # Usage: HighLine.supports_rgb_color? rescue false   # rescue for compatibility with older versions
  # Note: color usage also depends on HighLine.use_color being set
  def self.supports_rgb_color?
    true
  end

  # The setting used to disable EOF tracking.
  @track_eof = true

  # Pass +false+ to _setting_ to turn off HighLine's EOF tracking.
  def self.track_eof=( setting )
    @track_eof = setting
  end

  # Returns true if HighLine is currently tracking EOF for input.
  def self.track_eof?
    @track_eof
  end

  def track_eof?
    self.class.track_eof?
  end

  # The setting used to control color schemes.
  @color_scheme = nil

  # Pass ColorScheme to _setting_ to set a HighLine color scheme.
  def self.color_scheme=( setting )
    @color_scheme = setting
  end

  # Returns the current color scheme.
  def self.color_scheme
    @color_scheme
  end

  # Returns +true+ if HighLine is currently using a color scheme.
  def self.using_color_scheme?
    !!@color_scheme
  end

  # Reset HighLine to default.
  # Clears Style index and reset color scheme.
  def self.reset
    Style.clear_index
    reset_color_scheme
  end

  def self.reset_color_scheme
    self.color_scheme = nil
  end

  #
  # Create an instance of HighLine, connected to the streams _input_
  # and _output_.
  #
  def initialize( input = $stdin, output = $stdout,
                  wrap_at = nil, page_at = nil, indent_size=3, indent_level=0 )
    @input   = input
    @output  = output

    @multi_indent = true
    @indent_size = indent_size
    @indent_level = indent_level

    self.wrap_at = wrap_at
    self.page_at = page_at

    @header   = nil
    @prompt   = nil
    @key      = nil

    @terminal = HighLine::Terminal.get_terminal(input, output)
  end

  # The current column setting for wrapping output.
  attr_reader :wrap_at
  # The current row setting for paging output.
  attr_reader :page_at
  # Indentation over multiple lines
  attr_accessor :multi_indent
  # The indentation size
  attr_accessor :indent_size
  # The indentation level
  attr_accessor :indent_level

  attr_reader :input, :output

  attr_reader :key

  # System specific that responds to #initialize_system_extensions,
  # #terminal_size, #raw_no_echo_mode, #restore_mode, #get_character.
  # It polymorphically handles specific cases for different platforms.
  attr_reader :terminal

  #
  # A shortcut to HighLine.ask() a question that only accepts "yes" or "no"
  # answers ("y" and "n" are allowed) and returns +true+ or +false+
  # (+true+ for "yes").  If provided a +true+ value, _character_ will cause
  # HighLine to fetch a single character response. A block can be provided
  # to further configure the question as in HighLine.ask()
  #
  # Raises EOFError if input is exhausted.
  #
  def agree( yes_or_no_question, character = nil )
    ask(yes_or_no_question, lambda { |yn| yn.downcase[0] == ?y}) do |q|
      q.validate                 = /\Ay(?:es)?|no?\Z/i
      q.responses[:not_valid]    = 'Please enter "yes" or "no".'
      q.responses[:ask_on_error] = :question
      q.character                = character

      yield q if block_given?
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
  # Raises EOFError if input is exhausted.
  #
  def ask(template_or_question, answer_type = nil, &details)
    question = Question.build(template_or_question, answer_type, &details)
    question.ask_at(self)
  end

  #
  # This method is HighLine's menu handler.  For simple usage, you can just
  # pass all the menu items you wish to display.  At that point, choose() will
  # build and display a menu, walk the user through selection, and return
  # their choice among the provided items.  You might use this in a case
  # statement for quick and dirty menus.
  #
  # However, choose() is capable of much more.  If provided, a block will be
  # passed a HighLine::Menu object to configure.  Using this method, you can
  # customize all the details of menu handling from index display, to building
  # a complete shell-like menuing system.  See HighLine::Menu for all the
  # methods it responds to.
  #
  # Raises EOFError if input is exhausted.
  #
  def choose( *items, &details )
    menu = Menu.new(&details)
    menu.choices(*items) unless items.empty?

    # Set auto-completion
    menu.completion = menu.options

    shell_style_lambda = lambda do |command|    # shell-style selection
      first_word = command.to_s.split.first || ""

      options = menu.options
      options.extend(OptionParser::Completion)
      answer = options.complete(first_word)

      raise Question::NoAutoCompleteMatch unless answer

      [answer.last, command.sub(/^\s*#{first_word}\s*/, "")]
    end

    # Set _answer_type_ so we can double as the Question for ask().
    # menu.option = normal menu selection, by index or name
    menu.answer_type = menu.shell ? shell_style_lambda : menu.options

    selected = ask(menu)

    if menu.shell
      menu.select(self, *selected)
    else
      menu.select(self, selected)
    end
  end

  #
  # This method provides easy access to ANSI color sequences, without the user
  # needing to remember to CLEAR at the end of each sequence.  Just pass the
  # _string_ to color, followed by a list of _colors_ you would like it to be
  # affected by.  The _colors_ can be HighLine class constants, or symbols
  # (:blue for BLUE, for example).  A CLEAR will automatically be embedded to
  # the end of the returned String.
  #
  # This method returns the original _string_ unchanged if HighLine::use_color?
  # is +false+.
  #
  def self.color( string, *colors )
    return string unless self.use_color?
    Style(*colors).color(string)
  end

  # In case you just want the color code, without the embedding and the CLEAR
  def self.color_code(*colors)
    Style(*colors).code
  end

  # Works as an instance method, same as the class method
  def color_code(*colors)
    self.class.color_code(*colors)
  end

  # Works as an instance method, same as the class method
  def color(*args)
    self.class.color(*args)
  end

  # Remove color codes from a string
  def self.uncolor(string)
    Style.uncolor(string)
  end

  # Works as an instance method, same as the class method
  def uncolor(string)
    self.class.uncolor(string)
  end

  def list(items, mode = :rows, option = nil)
    ListRenderer.new(items, mode, option, self).render
  end

  #
  # The basic output method for HighLine objects.  If the provided _statement_
  # ends with a space or tab character, a newline will not be appended (output
  # will be flush()ed).  All other cases are passed straight to Kernel.puts().
  #
  # The _statement_ argument is processed as an ERb template, supporting
  # embedded Ruby code.  The template is evaluated within a HighLine
  # instance's binding for providing easy access to the ANSI color constants
  # and the HighLine#color() method.
  #
  def say(statement)
    statement = render_statement(statement)
    return if statement.empty?

    statement = (indentation+statement)

    # Don't add a newline if statement ends with whitespace, OR
    # if statement ends with whitespace before a color escape code.
    if /[ \t](\e\[\d+(;\d+)*m)?\Z/ =~ statement
      output.print(statement)
      output.flush
    else
      output.puts(statement)
    end
  end

  def render_statement(statement)
    Statement.new(statement, self).to_s
  end

  #
  # Set to an integer value to cause HighLine to wrap output lines at the
  # indicated character limit.  When +nil+, the default, no wrapping occurs.  If
  # set to <tt>:auto</tt>, HighLine will attempt to determine the columns
  # available for the <tt>@output</tt> or use a sensible default.
  #
  def wrap_at=( setting )
    @wrap_at = setting == :auto ? output_cols : setting
  end

  #
  # Set to an integer value to cause HighLine to page output lines over the
  # indicated line limit.  When +nil+, the default, no paging occurs.  If
  # set to <tt>:auto</tt>, HighLine will attempt to determine the rows available
  # for the <tt>@output</tt> or use a sensible default.
  #
  def page_at=( setting )
    @page_at = setting == :auto ? output_rows - 2 : setting
  end

  #
  # Outputs indentation with current settings
  #
  def indentation
    ' '*@indent_size*@indent_level
  end

  #
  # Executes block or outputs statement with indentation
  #
  def indent(increase=1, statement=nil, multiline=nil)
    @indent_level += increase
    multi = @multi_indent
    @multi_indent ||= multiline
    begin
      if block_given?
        yield self
      else
        say(statement)
      end
    ensure
      @multi_indent = multi
      @indent_level -= increase
    end
  end

  #
  # Outputs newline
  #
  def newline
    @output.puts
  end

  #
  # Returns the number of columns for the console, or a default it they cannot
  # be determined.
  #
  def output_cols
    return 80 unless @output.tty?
    terminal.terminal_size.first
  rescue
    return 80
  end

  #
  # Returns the number of rows for the console, or a default if they cannot be
  # determined.
  #
  def output_rows
    return 24 unless @output.tty?
    terminal.terminal_size.last
  rescue
    return 24
  end

  def puts(*args)
    @output.puts(*args)
  end

  #
  # Creates a new HighLine instance with the same options
  #
  def new_scope
    self.class.new(@input, @output, @wrap_at, @page_at, @indent_size, @indent_level)
  end

  private

  #
  # A helper method for sending the output stream and error and repeat
  # of the question.
  #
  def explain_error(error, question)
    say(question.responses[error]) if error
    say(question.ask_on_error_msg)
  end

  #
  # Gets one answer, as opposed to HighLine#gather
  #
  def ask_once(question)

    # readline() needs to handle its own output, but readline only supports
    # full line reading.  Therefore if question.echo is anything but true,
    # the prompt will not be issued. And we have to account for that now.
    # Also, JRuby-1.7's ConsoleReader.readLine() needs to be passed the prompt
    # to handle line editing properly.
    say(question) unless ((question.readline) and (question.echo == true and !question.limit))

    begin
      question.get_response_or_default(self)
      raise NotValidQuestionError unless question.valid_answer?

      question.convert

      if question.confirm
        # need to add a layer of scope (new_scope) to ask a question inside a
        # question, without destroying instance data

        raise NoConfirmationQuestionError unless confirm(question)
      end

    rescue NoConfirmationQuestionError
      explain_error(nil, question)
      retry

    rescue NotInRangeQuestionError
      explain_error(:not_in_range, question)
      retry

    rescue NotValidQuestionError
      explain_error(:not_valid, question)
      retry

    rescue QuestionError
      retry

    rescue ArgumentError => error
      case error.message
      when /ambiguous/
        # the assumption here is that OptionParser::Completion#complete
        # (used for ambiguity resolution) throws exceptions containing
        # the word 'ambiguous' whenever resolution fails
        explain_error(:ambiguous_completion, question)
        retry
      when /invalid value for/
        explain_error(:invalid_type, question)
        retry
      else
        raise
      end

    rescue Question::NoAutoCompleteMatch
      explain_error(:no_completion, question)
      retry
    end
    question.answer
  end

  def confirm(question)
    new_scope.agree(question.confirm_question(self))
  end


  public :ask_once

  #
  # Collects an Array/Hash full of answers as described in
  # HighLine::Question.gather().
  #
  # Raises EOFError if input is exhausted.
  #
  def gather(question)
    original_question_template = question.template
    verify_match = question.verify_match

    begin   # when verify_match is set this loop will repeat until unique_answers == 1
      question.template = original_question_template

      answers =
      case question.gather
      when Integer
        gather_integer(question)
      when ::String, Regexp
        gather_regexp(question)
      when Hash
        gather_hash(question)
      end

      if verify_match && (unique_answers(answers).size > 1)
        explain_error(:mismatch, question)
      else
        verify_match = false
      end

    end while verify_match

    question.verify_match ? last_answer(answers) : answers
  end

  public :gather

  def gather_integer(question)
    answers = []

    answers << ask_once(question)

    question.template = ""

    (question.gather-1).times do
      answers  << ask_once(question)
    end

    answers
  end

  def gather_regexp(question)
    answers = []

    answers << ask_once(question)

    question.template = ""
    until (question.gather.is_a?(::String) and answers.last.to_s == question.gather) or
        (question.gather.is_a?(Regexp) and answers.last.to_s =~ question.gather)
      answers  << ask_once(question)
    end

    answers.pop
    answers
  end

  def gather_hash(question)
    answers = {}

    question.gather.keys.sort.each do |key|
      @key          = key
      answers[key] = ask_once(question)
    end
    answers
  end

  #
  # A helper method used by HighLine::Question.verify_match
  # for finding whether a list of answers match or differ
  # from each other.
  #
  def unique_answers(list)
    (list.respond_to?(:values) ? list.values : list).uniq
  end

  def last_answer(answers)
    answers.respond_to?(:values) ? answers.values.last : answers.last
  end

  #
  # Read a line of input from the input stream and process whitespace as
  # requested by the Question object.
  #
  # If Question's _readline_ property is set, that library will be used to
  # fetch input.  *WARNING*:  This ignores the currently set input stream.
  #
  # Raises EOFError if input is exhausted.
  #
  def get_line(question)
    terminal.get_line(question, self)
  end

  def get_response_line_mode(question)
    if question.echo == true and !question.limit
      get_line(question)
    else
      line = ""

      terminal.raw_no_echo_mode_exec do
        while character = terminal.get_character
          break if character == "\n" or character == "\r"

          # honor backspace and delete
          if character == "\b"
            chopped = line.chop!
            output_erase_char if chopped and question.echo
          else
            line << character
            @output.print(line[-1]) if question.echo == true
            @output.print(question.echo) if question.echo and question.echo != true
          end

          @output.flush

          break if question.limit and line.size == question.limit
        end
      end

      if question.overwrite
        @output.print("\r#{HighLine.Style(:erase_line).code}")
        @output.flush
      else
        say("\n")
      end

      question.format_answer(line)
    end
  end

  def output_erase_char
    @output.print("\b#{HighLine.Style(:erase_char).code}")
  end

  def get_response_getc_mode(question)
    terminal.raw_no_echo_mode_exec do
      response = @input.getc
      question.format_answer(response)
    end
  end

  def get_response_character_mode(question)
    terminal.raw_no_echo_mode_exec do
      response = terminal.get_character
      if question.overwrite
        erase_current_line
      else
        echo = get_echo(question, response)
        say("#{echo}\n")
      end
      question.format_answer(response)
    end
  end

  def erase_current_line
    @output.print("\r#{HighLine.Style(:erase_line).code}")
    @output.flush
  end

  def get_echo(question, response)
    if question.echo == true
      response
    elsif question.echo != false
      question.echo
    else
      ""
    end
  end

  public :get_response_character_mode, :get_response_line_mode
  public :get_response_getc_mode

  def actual_length(text)
    Wrapper.actual_length text
  end
end

require "highline/string"
