# coding: utf-8

class HighLine
  class Terminal
    class IOConsole < Terminal
      def terminal_size
        output.winsize.reverse
      end

      CHARACTER_MODE = "io_console"   # For Debugging purposes only.

      def raw_no_echo_mode
        input.echo = false
      end

      def restore_mode
        input.echo = true
      end

      def get_character
        input.getch # from ruby io/console
      end

      def character_mode
        "io_console"
      end
    end
  end
end