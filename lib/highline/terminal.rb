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
