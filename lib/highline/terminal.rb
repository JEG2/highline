#!/usr/bin/env ruby
# coding: utf-8

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
    def self.get_terminal
      require 'highline/terminal/unix_stty'
      terminal = HighLine::Terminal::UnixStty.new
      terminal.initialize_system_extensions
      terminal
    end

    def initialize_system_extensions
    end

    def terminal_size
    end

    def raw_no_echo_mode
    end

    def raw_no_echo_mode_exec
      raw_no_echo_mode
      begin
        yield
      ensure
        restore_mode
      end
    end

    def restore_mode
    end

    def get_character
    end

    def jruby?
      defined?(RUBY_ENGINE) && RUBY_ENGINE == 'jruby'
    end
  end
end

=begin

# Meanwhile, we're concentratring on making a standard
# terminal to work using this new approach.
#
# We'll try to revive the code bellow as soon as possible.

      JRUBY = defined?(RUBY_ENGINE) && RUBY_ENGINE == 'jruby'

      if JRUBY
        require 'highline/terminal/jruby'
        return HighLine::Terminal::JRuby
      end

      extend self

      #
      # This section builds character reading and terminal size functions
      # to suit the proper platform we're running on.  Be warned:  Here be
      # dragons!
      #
      if RUBY_PLATFORM =~ /mswin(?!ce)|mingw|bccwin/i
        begin
          require 'highline/terminal/windows_fiddle'
          return HighLine::Terminal::WindowsFiddle
        rescue LoadError
          require 'highline/terminal/windows_dl_import'
          return HighLine::Terminal::WindowsDlImport
        end

        require 'highline/terminal/windows'
        return HighLine::Terminal::Windows
      else                  # If we're not on Windows try...
        begin
          require 'highline/terminal/unix_termios'
          return HighLine::Terminal::UnixTermios
        rescue LoadError                # If our first choice fails, try using JLine
          if JRUBY                      # if we are on JRuby. JLine is bundled with JRuby.
            require 'highline/terminal/jruby_jline'
            return HighLine::Terminal::JRubyJLine
          else                          # If we are not on JRuby, try ncurses
            begin
              require 'highline/terminal/ncurses'
              return HighLine::Terminal::NCurses
            rescue LoadError            # Finally, if all else fails, use stty
              require 'highline/terminal/stty'
              return HighLine::Terminal::Stty
            end
          end
        end

        # For termios and stty
        if not method_defined?(:terminal_size)
          require 'highline/terminal/unix_stty'
          return HighLine::Terminal::UnixStty
        end
      end

      if not method_defined?(:get_character)
        def get_character( input = STDIN )
          input.getbyte
        end
      end
    end
  end
end
=end
