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
    def self.get_terminal
      terminal = nil

      # First of all, probe for io/console
      begin
        require "io/console"
        require "highline/terminal/io_console"
        terminal = HighLine::Terminal::IOConsole.new
      rescue LoadError
      end

      # Fall back to UnixStty
      unless terminal
        require 'highline/terminal/unix_stty'
        terminal = HighLine::Terminal::UnixStty.new
      end

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
