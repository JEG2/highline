class HighLine
  module SystemExtensions
    module UnixTermios
      require "termios"             # Unix, first choice termios.

      CHARACTER_MODE = "termios"    # For Debugging purposes only.

      def raw_no_echo_mode
        @state = Termios.getattr(@input)
        new_settings                     =  @state.dup
        new_settings.c_lflag             &= ~(Termios::ECHO | Termios::ICANON)
        new_settings.c_cc[Termios::VMIN] =  1
        Termios.setattr(@input, Termios::TCSANOW, new_settings)
      end

      def restore_mode
        Termios.setattr(@input, Termios::TCSANOW, @state)
      end
    end
  end
end