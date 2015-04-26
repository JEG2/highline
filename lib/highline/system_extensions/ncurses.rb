class HighLine
  module SystemExtensions
    module NCurses
      require 'ffi-ncurses'
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
          size = FFI::NCurses.getmaxyx(FFI::NCurses.stdscr).reverse
        ensure
          FFI::NCurses.endwin
        end
        size
      end
    end
  end
end