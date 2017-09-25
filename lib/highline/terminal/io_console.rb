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

      # (see Terminal#raw_no_echo_mode)
      def raw_no_echo_mode
        input.echo = false
      end

      # (see Terminal#restore_mode)
      def restore_mode
        input.echo = true
      end

      # (see Terminal#get_character)
      def get_character # rubocop:disable Naming/AccessorMethodName
        input.getch # from ruby io/console
      end
    end
  end
end
