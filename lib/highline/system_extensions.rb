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

    def get_character( input = STDIN )
      input.getbyte
    end

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

      # We do not define a raw_no_echo_mode for Windows as _getch turns off echo
      def raw_no_echo_mode
      end

      def restore_mode
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

        def raw_no_echo_mode
          @state = Termios.getattr(input)
          new_settings                     =  @state.dup
          new_settings.c_lflag             &= ~(Termios::ECHO | Termios::ICANON)
          new_settings.c_cc[Termios::VMIN] =  1
          Termios.setattr(input, Termios::TCSANOW, new_settings)
        end

        def restore_mode
            Termios.setattr(input, Termios::TCSANOW, @state)
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

          def raw_no_echo_mode
            FFI::NCurses.initscr
            FFI::NCurses.cbreak
          end

          def restore_mode
            FFI::NCurses.endwin
          end

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
        rescue LoadError
          if JRUBY                # If the ffi-ncurses choice fails, use Jline
            require 'java'        # if we are on JRuby

            CHARACTER_MODE = "jline"   # For Debugging purposes only.


            def terminal_size
              java_terminal = @java_console.getTerminal
              [ java_terminal.getTerminalWidth, java_terminal.getTerminalHeight ]
            end

            def raw_no_echo_mode
              @state = @java_console.getEchoCharacter
              @java_console.setEchoCharacter 0
            end

            def restore_mode
              @java_console.setEchoCharacter @state
            end
          else                    # As a final choice, use stty
                                  # *WARNING*:  This method requires the external "stty" program!
            CHARACTER_MODE = "stty"    # For Debugging purposes only.

            def raw_no_echo_mode
              @state = `stty -g`
              system "stty raw -echo -icanon isig"
            end

            def restore_mode
              system "stty #{@state}"
            end
          end
        end
      end

      # For termios and stty
      if not defined?(terminal_size)
        # A Unix savvy method using stty to fetch the console columns, and rows.
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
