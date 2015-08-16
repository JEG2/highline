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

      def get_line(question, highline, options={})
        raw_answer =
        if question.readline
          get_line_with_readline(question, highline, options={})
        else
          get_line_default(highline)
        end

        question.format_answer(raw_answer)
      end

      def get_line_with_readline(question, highline, options={})
        require "readline"    # load only if needed

        question_string = highline.render_statement(question)

        raw_answer = readline_read(question_string, question)

        if !raw_answer and highline.track_eof?
          raise EOFError, "The input stream is exhausted."
        end

        raw_answer || ""
      end

      def readline_read(string, question)
        # prep auto-completion
        unless question.selection.empty?
          Readline.completion_proc = lambda do |str|
            question.selection.grep(/\A#{Regexp.escape(str)}/)
          end
        end

        # work-around ugly readline() warnings
        old_verbose = $VERBOSE
        $VERBOSE    = nil
        raw_answer  = Readline.readline(string, true)

        $VERBOSE    = old_verbose

        raw_answer
      end

      def get_line_default(highline)
        raise EOFError, "The input stream is exhausted." if highline.track_eof? and
                                                              highline.input.eof?
        highline.input.gets
      end
    end
  end
end