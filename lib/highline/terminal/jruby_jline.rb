# coding: utf-8

class HighLine
  module SystemExtensions
    module JRubyJLine
      CHARACTER_MODE = "jline"    # For Debugging purposes only.

      def terminal_size
        if JRUBY_VERSION =~ /^1.7/
          [ @java_terminal.get_width, @java_terminal.get_height ]
        else
          [ @java_terminal.getTerminalWidth, @java_terminal.getTerminalHeight ]
        end
      end

      def raw_no_echo_mode
        @state = @java_console.getEchoCharacter
        @java_console.setEchoCharacter 0
      end

      def restore_mode
        @java_console.setEchoCharacter @state
      end

      # Saving this legacy JRuby code for future reference
      def get_line(question, highline, options={})
        statement = highline.render_statement(question)
        raw_answer = @java_console.readLine(statement, nil)

        raise EOFError, "The input stream is exhausted." if !raw_answer and
                                                            highline.track_eof?
      end
    end
  end
end