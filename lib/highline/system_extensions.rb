#!/usr/bin/env ruby
# coding: utf-8

# system_extensions.rb
#
#  Created by James Edward Gray II on 2006-06-14.
#  Copyright 2006 Gray Productions. All rights reserved.
#
#  This is Free Software.  See LICENSE and COPYING for details.

require "highline/compatibility"

class HighLine
  module SystemExtensions
    JRUBY = defined?(RUBY_ENGINE) && RUBY_ENGINE == 'jruby'

    if JRUBY
      require 'highline/system_extensions/jruby'
      include HighLine::SystemExtensions::JRuby
    end

    extend self

    #
    # This section builds character reading and terminal size functions
    # to suit the proper platform we're running on.  Be warned:  Here be
    # dragons!
    #
    if RUBY_PLATFORM =~ /mswin(?!ce)|mingw|bccwin/i
      begin
        require 'highline/system_extensions/windows_fiddle'
        include HighLine::SystemExtensions::WindowsFiddle
      rescue LoadError
        require 'highline/system_extensions/windows_dl_import'
        include HighLine::SystemExtensions::WindowsDlImport
      end

      require 'highline/system_extensions/windows'
      include HighLine::SystemExtensions::Windows
    else                  # If we're not on Windows try...
      begin
        require 'highline/system_extensions/unix_termios'
        include HighLine::SystemExtensions::UnixTermios
      rescue LoadError                # If our first choice fails, try using JLine
        if JRUBY                      # if we are on JRuby. JLine is bundled with JRuby.
          require 'highline/system_extensions/jruby_jline'
          include HighLine::SystemExtensions::JRubyJLine
        else                          # If we are not on JRuby, try ncurses
          begin
            require 'highline/system_extensions/ncurses'
            include HighLine::SystemExtensions::NCurses
          rescue LoadError            # Finally, if all else fails, use stty
            require 'highline/system_extensions/stty'
            include HighLine::SystemExtensions::Stty
          end
        end
      end

      # For termios and stty
      if not method_defined?(:terminal_size)
        require 'highline/system_extensions/unix_stty'
        include HighLine::SystemExtensions::UnixStty
      end
    end

    if not method_defined?(:get_character)
      def get_character( input = STDIN )
        input.getbyte
      end
    end
  end
end
