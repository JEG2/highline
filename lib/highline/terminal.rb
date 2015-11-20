# coding: utf-8

#--
# terminal.rb
#
#  Originally created by James Edward Gray II on 2006-06-14 as
#  system_extensions.rb.
#  Copyright 2006 Gray Productions. All rights reserved.
#
#  This is Free Software.  See LICENSE and COPYING for details.

require "highline/compatibility"

class HighLine
  class Terminal
    def self.get_terminal(input, output)
      terminal = nil

      # First of all, probe for io/console
      begin
        require "io/console"
        require "highline/terminal/io_console"
        terminal = HighLine::Terminal::IOConsole.new(input, output)
      rescue LoadError
      end

      # Fall back to UnixStty
      unless terminal
        require 'highline/terminal/unix_stty'
        terminal = HighLine::Terminal::UnixStty.new(input, output)
      end

      terminal.initialize_system_extensions
      terminal
    end

    attr_reader :input, :output

    def initialize(input, output)
      @input  = input
      @output = output
    end

    def initialize_system_extensions
    end

    def terminal_size
    end

    def raw_no_echo_mode
    end

    def raw_no_echo_mode_exec
      raw_no_echo_mode
      yield
    ensure
      restore_mode
    end

    def restore_mode
    end

    def get_character
    end

    def get_line(question, highline, options={})
      raw_answer =
      if question.readline
        get_line_with_readline(question, highline, options={})
      else
        get_line_default(highline)
      end

      question.format_answer(raw_answer)
    end

    def get_line_with_readline(question, highline, options={})
      require "readline"    # load only if needed

      question_string = highline.render_statement(question)

      raw_answer = readline_read(question_string, question)

      if !raw_answer and highline.track_eof?
        raise EOFError, "The input stream is exhausted."
      end

      raw_answer || ""
    end

    def readline_read(string, question)
      # prep auto-completion
      unless question.selection.empty?
        Readline.completion_proc = lambda do |str|
          question.selection.grep(/\A#{Regexp.escape(str)}/)
        end
      end

      # work-around ugly readline() warnings
      old_verbose = $VERBOSE
      $VERBOSE    = nil

      raw_answer  = run_preserving_stty do
        Readline.readline(string, true)
      end

      $VERBOSE    = old_verbose

      raw_answer
    end

    def get_line_default(highline)
      raise EOFError, "The input stream is exhausted." if highline.track_eof? and
                                                            highline.input.eof?
      highline.input.gets
    end

    def jruby?
      defined?(RUBY_ENGINE) && RUBY_ENGINE == 'jruby'
    end

    def rubinius?
      defined?(RUBY_ENGINE) && RUBY_ENGINE == 'rbx'
    end

    def windows?
      defined?(RUBY_PLATFORM) && (RUBY_PLATFORM =~ /mswin|mingw|cygwin/)
    end

    private

    def run_preserving_stty
      save_stty
      yield
    ensure
      restore_stty
    end

    def save_stty
      @stty_save = `stty -g`.chomp rescue nil
    end

    def restore_stty
      system("stty", @stty_save) if @stty_save
    end
  end
end
