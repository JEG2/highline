# system_extensions.rb
#
#  Created by James Edward Gray II on 2006-06-14.
#  Copyright 2006 Gray Productions. All rights reserved.
#
#  This is Free Software.  See LICENSE and COPYING for details.

require "highline/compatibility"

class HighLine
  module SystemExtensions
    module_function

    JRUBY = defined?(RUBY_ENGINE) && RUBY_ENGINE == 'jruby'

    #
    # This section builds character reading and terminal size functions
    # to suit the proper platform we're running on.  Be warned:  Here be
    # dragons!
    #
    begin
      # Cygwin will look like Windows, but we want to treat it like a Posix OS:
      raise LoadError, "Cygwin is a Posix OS." if RUBY_PLATFORM =~ /\bcygwin\b/i

      require "Win32API"             # See if we're on Windows.

      CHARACTER_MODE = "Win32API"    # For Debugging purposes only.

      #
      # Windows savvy getc().
      #
      # *WARNING*:  This method ignores <tt>input</tt> and reads one
      # character from +STDIN+!
      #
      def get_character( input = STDIN )
        Win32API.new("msvcrt", "_getch", [ ], "L").Call
      rescue Exception
        Win32API.new("crtdll", "_getch", [ ], "L").Call
      end

      # A Windows savvy method to fetch the console columns, and rows.
      def terminal_size
        m_GetStdHandle               = Win32API.new( 'kernel32',
                                                     'GetStdHandle',
                                                     ['L'],
                                                     'L' )
        m_GetConsoleScreenBufferInfo = Win32API.new(
          'kernel32', 'GetConsoleScreenBufferInfo', ['L', 'P'], 'L'
        )

        format        = 'SSSSSssssSS'
        buf           = ([0] * format.size).pack(format)
        stdout_handle = m_GetStdHandle.call(0xFFFFFFF5)

        m_GetConsoleScreenBufferInfo.call(stdout_handle, buf)
        _, _, _, _, _,
        left, top, right, bottom, _, _ = buf.unpack(format)
        return right - left + 1, bottom - top + 1
      end
    rescue LoadError                  # If we're not on Windows try...
      begin
        require "termios"             # Unix, first choice termios.

        CHARACTER_MODE = "termios"    # For Debugging purposes only.

        #
        # Unix savvy getc().  (First choice.)
        #
        # *WARNING*:  This method requires the "termios" library!
        #
        def get_character( input = STDIN )
          return input.getbyte if input.is_a? StringIO

          old_settings = Termios.getattr(input)

          new_settings                     =  old_settings.dup
          new_settings.c_lflag             &= ~(Termios::ECHO | Termios::ICANON)
          new_settings.c_cc[Termios::VMIN] =  1

          begin
            Termios.setattr(input, Termios::TCSANOW, new_settings)
            input.getbyte
          ensure
            Termios.setattr(input, Termios::TCSANOW, old_settings)
          end
        end
      rescue LoadError            # If our first choice fails, try using ffi-ncurses.
        begin
          require 'ffi-ncurses'   # The ffi gem is builtin to JRUBY and because stty does not
                                  # work correctly in JRuby manually installing the ffi-ncurses
                                  # gem is the only way to get highline to operate correctly in
                                  # JRuby. The ncurses library is only present on unix platforms
                                  # so this is not a solution for using highline in JRuby on
                                  # windows.

          CHARACTER_MODE = "ncurses"    # For Debugging purposes only.

          #
          # ncurses savvy getc().
          #
          def get_character( input = STDIN )
            FFI::NCurses.initscr
            FFI::NCurses.cbreak
            begin
              FFI::NCurses.curs_set 0
              input.getbyte
            ensure
              FFI::NCurses.endwin
            end
          end

        rescue LoadError                # If the ffi-ncurses choice fails, try using stty
          CHARACTER_MODE = "stty"    # For Debugging purposes only.

          #
          # Unix savvy getc().  (Second choice.)
          #
          # *WARNING*:  This method requires the external "stty" program!
          #
          def get_character( input = STDIN )
            raw_no_echo_mode

            begin
              input.getbyte
            ensure
              restore_mode
            end
          end

          #
          # Switched the input mode to raw and disables echo.
          #
          # *WARNING*:  This method requires the external "stty" program!
          #
          def raw_no_echo_mode
            @state = `stty -g`
            system "stty raw -echo -icanon isig"
          end

          #
          # Restores a previously saved input mode.
          #
          # *WARNING*:  This method requires the external "stty" program!
          #
          def restore_mode
            system "stty #{@state}"
          end
        end
      end
      if CHARACTER_MODE == 'ncurses'
        #
        # A ncurses savvy method to fetch the console columns, and rows.
        #
        def terminal_size
          size = [80, 40]
          FFI::NCurses.initscr
          begin
            size = FFI::NCurses.getmaxyx(stdscr).reverse
          ensure
            FFI::NCurses.endwin
          end
          size
        end
      elsif JRUBY
        # JRuby running on Unix can fetch the number of columns and rows from the builtin Jline library
        require 'java'
        java_import 'jline.Terminal'
        def terminal_size
          java_terminal = @java_terminal || Terminal.getTerminal
          [ java_terminal.getTerminalWidth, java_terminal.getTerminalHeight ]
        end
      else
        # A Unix savvy method using stty that to fetch the console columns, and rows.
        # ... stty does not work in JRuby
        def terminal_size
          if /solaris/ =~ RUBY_PLATFORM and
            `stty` =~ /\brows = (\d+).*\bcolumns = (\d+)/
            [$2, $1].map { |c| x.to_i }
          else
            `stty size`.split.map { |x| x.to_i }.reverse
          end
        end
      end
    end
  end
end
