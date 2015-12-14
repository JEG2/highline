# coding: utf-8

class HighLine
  class Terminal
    # io/console option for HighLine::Terminal.
    # It's the most used terminal.
    class IOConsole < Terminal
      # (see Terminal#terminal_size)
      def terminal_size
        output.winsize.reverse
      end

      # Easy to query active terminal (character mode).
      # For debugging purposes.
      CHARACTER_MODE = "io_console"   # For Debugging purposes only.

      # (see Terminal#raw_no_echo_mode)
      def raw_no_echo_mode
        input.echo = false
      end

      # (see Terminal#restore_mode)
      def restore_mode
        input.echo = true
      end

      # (see Terminal#get_character)
      def get_character
        input.getch # from ruby io/console
      end

      # Same as CHARACTER_MODE constant. "io_console"
      def character_mode
        "io_console"
      end
    end
  end
end