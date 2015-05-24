#!/usr/bin/env ruby
# coding: utf-8

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
  # An internal HighLine error.  User code does not need to trap this.
  class QuestionError < StandardError
    # do nothing, just creating a unique error type
  end

  # The setting used to disable color output.
  @@use_color = true

  # Pass +false+ to _setting_ to turn off HighLine's color escapes.
  def self.use_color=( setting )
    @@use_color = setting
  end

  # Returns true if HighLine is currently using color escapes.
  def self.use_color?
    @@use_color
  end

  # For checking if the current version of HighLine supports RGB colors
  # Usage: HighLine.supports_rgb_color? rescue false   # rescue for compatibility with older versions
  # Note: color usage also depends on HighLine.use_color being set
  def self.supports_rgb_color?
    true
  end

  # The setting used to disable EOF tracking.
  @@track_eof = true

  # Pass +false+ to _setting_ to turn off HighLine's EOF tracking.
  def self.track_eof=( setting )
    @@track_eof = setting
  end

  # Returns true if HighLine is currently tracking EOF for input.
  def self.track_eof?
    @@track_eof
  end

  def track_eof?
    self.class.track_eof?
  end

  # The setting used to control color schemes.
  @@color_scheme = nil

  # Pass ColorScheme to _setting_ to set a HighLine color scheme.
  def self.color_scheme=( setting )
    @@color_scheme = setting
  end

  # Returns the current color scheme.
  def self.color_scheme
    @@color_scheme
  end

  # Returns +true+ if HighLine is currently using a color scheme.
  def self.using_color_scheme?
    not @@color_scheme.nil?
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
  # Embed in a String to clear all previous ANSI sequences.  This *MUST* be
  # done before the program exits!
  #

  ERASE_LINE_STYLE = Style.new(:name=>:erase_line, :builtin=>true, :code=>"\e[K")  # Erase the current line of terminal output
  ERASE_CHAR_STYLE = Style.new(:name=>:erase_char, :builtin=>true, :code=>"\e[P")  # Erase the character under the cursor.
  CLEAR_STYLE      = Style.new(:name=>:clear,      :builtin=>true, :code=>"\e[0m") # Clear color settings
  RESET_STYLE      = Style.new(:name=>:reset,      :builtin=>true, :code=>"\e[0m") # Alias for CLEAR.
  BOLD_STYLE       = Style.new(:name=>:bold,       :builtin=>true, :code=>"\e[1m") # Bold; Note: bold + a color works as you'd expect,
                                                              # for example bold black. Bold without a color displays
                                                              # the system-defined bold color (e.g. red on Mac iTerm)
  DARK_STYLE       = Style.new(:name=>:dark,       :builtin=>true, :code=>"\e[2m") # Dark; support uncommon
  UNDERLINE_STYLE  = Style.new(:name=>:underline,  :builtin=>true, :code=>"\e[4m") # Underline
  UNDERSCORE_STYLE = Style.new(:name=>:underscore, :builtin=>true, :code=>"\e[4m") # Alias for UNDERLINE
  BLINK_STYLE      = Style.new(:name=>:blink,      :builtin=>true, :code=>"\e[5m") # Blink; support uncommon
  REVERSE_STYLE    = Style.new(:name=>:reverse,    :builtin=>true, :code=>"\e[7m") # Reverse foreground and background
  CONCEALED_STYLE  = Style.new(:name=>:concealed,  :builtin=>true, :code=>"\e[8m") # Concealed; support uncommon

  STYLES = %w{CLEAR RESET BOLD DARK UNDERLINE UNDERSCORE BLINK REVERSE CONCEALED}

  # These RGB colors are approximate; see http://en.wikipedia.org/wiki/ANSI_escape_code
  BLACK_STYLE      = Style.new(:name=>:black,      :builtin=>true, :code=>"\e[30m", :rgb=>[  0,  0,  0])
  RED_STYLE        = Style.new(:name=>:red,        :builtin=>true, :code=>"\e[31m", :rgb=>[128,  0,  0])
  GREEN_STYLE      = Style.new(:name=>:green,      :builtin=>true, :code=>"\e[32m", :rgb=>[  0,128,  0])
  BLUE_STYLE       = Style.new(:name=>:blue,       :builtin=>true, :code=>"\e[34m", :rgb=>[  0,  0,128])
  YELLOW_STYLE     = Style.new(:name=>:yellow,     :builtin=>true, :code=>"\e[33m", :rgb=>[128,128,  0])
  MAGENTA_STYLE    = Style.new(:name=>:magenta,    :builtin=>true, :code=>"\e[35m", :rgb=>[128,  0,128])
  CYAN_STYLE       = Style.new(:name=>:cyan,       :builtin=>true, :code=>"\e[36m", :rgb=>[  0,128,128])
  # On Mac OSX Terminal, white is actually gray
  WHITE_STYLE      = Style.new(:name=>:white,      :builtin=>true, :code=>"\e[37m", :rgb=>[192,192,192])
  # Alias for WHITE, since WHITE is actually a light gray on Macs
  GRAY_STYLE       = Style.new(:name=>:gray,       :builtin=>true, :code=>"\e[37m", :rgb=>[192,192,192])
  GREY_STYLE       = Style.new(:name=>:grey,       :builtin=>true, :code=>"\e[37m", :rgb=>[192,192,192])
  # On Mac OSX Terminal, this is black foreground, or bright white background.
  # Also used as base for RGB colors, if available
  NONE_STYLE       = Style.new(:name=>:none,       :builtin=>true, :code=>"\e[38m", :rgb=>[  0,  0,  0])

  BASIC_COLORS = %w{BLACK RED GREEN YELLOW BLUE MAGENTA CYAN WHITE GRAY GREY NONE}

  colors = BASIC_COLORS.dup
  BASIC_COLORS.each do |color|
    bright_color = "BRIGHT_#{color}"
    colors << bright_color
    const_set bright_color+'_STYLE', const_get(color + '_STYLE').bright

    light_color = "LIGHT_#{color}"
    colors << light_color
    const_set light_color+'_STYLE', const_get(color + '_STYLE').light
  end
  COLORS = colors

  colors.each do |color|
    const_set color, const_get("#{color}_STYLE").code
    const_set "ON_#{color}_STYLE", const_get("#{color}_STYLE").on
    const_set "ON_#{color}", const_get("ON_#{color}_STYLE").code
  end
  ON_NONE_STYLE.rgb = [255,255,255] # Override; white background

  STYLES.each do |style|
    const_set style, const_get("#{style}_STYLE").code
  end

  # For RGB colors:
  def self.const_missing(name)
    if name.to_s =~ /^(ON_)?(RGB_)([A-F0-9]{6})(_STYLE)?$/ # RGB color
      on = $1
      suffix = $4
      if suffix
        code_name = $1.to_s + $2 + $3
      else
        code_name = name.to_s
      end
      style_name = code_name + '_STYLE'
      style = Style.rgb($3)
      style = style.on if on
      const_set(style_name, style)
      const_set(code_name, style.code)
      if suffix
        style
      else
        style.code
      end
    else
      raise NameError, "Bad color or uninitialized constant #{name}"
    end
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

    @question = nil
    @header   = nil
    @prompt   = nil
    @key      = nil

    @terminal = HighLine::Terminal.get_terminal
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

  attr_reader :question

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
  # If <tt>@question</tt> is set before ask() is called, parameters are
  # ignored and that object (must be a HighLine::Question) is used to drive
  # the process instead.
  #
  # Raises EOFError if input is exhausted.
  #
  def ask(template_or_question, answer_type = nil, options = {}, &details) # :yields: question
    if template_or_question.is_a? Question
      @question = template_or_question
    else
      @question = Question.new(template_or_question, answer_type, &details)
    end

    return question.ask_at(self)
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
  # The _statement_ parameter is processed as an ERb template, supporting
  # embedded Ruby code.  The template is evaluated with a binding inside
  # the HighLine instance, providing easy access to the ANSI color constants
  # and the HighLine.color() method.
  #
  def say( statement )
    statement = render_statement(statement)
    return if statement.empty?

    out = (indentation+statement)

    # Don't add a newline if statement ends with whitespace, OR
    # if statement ends with whitespace before a color escape code.
    if /[ \t](\e\[\d+(;\d+)*m)?\Z/ =~ statement
      @output.print(out)
      @output.flush
    else
      @output.puts(out)
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
    @multi_indent = multiline || @multi_indent
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
    say(question.responses[error]) unless error.nil?
    if question.responses[:ask_on_error] == :question
      say(question)
    elsif question.responses[:ask_on_error]
      say(question.responses[:ask_on_error])
    end
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
    say(question) unless ((question.readline) and (question.echo == true and question.limit.nil?))

    begin
      question.answer = question.answer_or_default(question.get_response(self))
      unless question.valid_answer?(question.answer)
        explain_error(:not_valid, question)
        raise QuestionError
      end

      question.answer = question.convert(question.answer)

      if question.in_range?(question.answer)
        if question.confirm
          # need to add a layer of scope to ask a question inside a
          # question, without destroying instance data
          context_change = new_scope
          if question.confirm == true
            confirm_question = "Are you sure?  "
          else
            # evaluate ERb under initial scope, so it will have
            # access to question and answer
            template  = ERB.new(question.confirm, nil, "%")
            template_renderer = TemplateRenderer.new(template, question, self)
            confirm_question = template_renderer.render
          end
          unless context_change.agree(confirm_question)
            explain_error(nil, question)
            raise QuestionError
          end
        end
      else
        explain_error(:not_in_range, question)
        raise QuestionError
      end
    rescue QuestionError
      retry

    # TODO: So we don't forget it!!!
    # This is a HUGE source of error mask
    # It's hiding errors deep in the code
    # It rescues and retries
    # We gotta remove it soon
    #
    # UPDATE: The rescue for invalid type
    # was made a little more specific.
    # Damage controlled meantime!
    rescue ArgumentError, NameError => error
      raise if error.is_a?(NoMethodError)
      if error.message =~ /ambiguous/
        # the assumption here is that OptionParser::Completion#complete
        # (used for ambiguity resolution) throws exceptions containing
        # the word 'ambiguous' whenever resolution fails
        explain_error(:ambiguous_completion, question)
        retry
      elsif error.is_a? ArgumentError and error.message =~ /invalid value for/
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
    if question.echo == true and question.limit.nil?
      get_line(question)
    else
      line            = ""
      backspace_limit = 0

      terminal.raw_no_echo_mode_exec do
        while character = terminal.get_character(@input)
          # honor backspace and delete
          if character == "\b"
            line.chop!
            backspace_limit -= 1
          else
            line << character
            backspace_limit = line.size
          end
          # looking for carriage return (decimal 13) or
          # newline (decimal 10) in raw input
          break if character == "\n" or character == "\r"
          if question.echo != false
            if character == "\b"
              # only backspace if we have characters on the line to
              # eliminate, otherwise we'll tromp over the prompt
              if backspace_limit >= 0 then
                @output.print("\b#{HighLine.Style(:erase_char).code}")
              else
                  # do nothing
              end
            else
              if question.echo == true
                @output.print(line[-1])
              else
                @output.print(question.echo)
              end
            end
            @output.flush
          end
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

  def get_response_getc_mode(question)
    terminal.raw_no_echo_mode_exec do
      response = @input.getc
      question.format_answer(response)
    end
  end

  def get_response_character_mode(question)
    terminal.raw_no_echo_mode_exec do
      response = terminal.get_character(@input)
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

require "highline/string_extensions"
