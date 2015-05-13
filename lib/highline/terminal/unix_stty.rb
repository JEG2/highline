class HighLine
  class Terminal::UnixStty < Terminal

    # A Unix savvy method using stty to fetch the console columns, and rows.
    # ... stty does not work in JRuby
    def terminal_size
      begin
        require "io/console"
        winsize = IO.console.winsize.reverse rescue nil
        return winsize if winsize
      rescue LoadError
      end

      if /solaris/ =~ RUBY_PLATFORM and
        `stty` =~ /\brows = (\d+).*\bcolumns = (\d+)/
        [$2, $1].map { |c| x.to_i }
      elsif `stty size` =~ /^(\d+)\s(\d+)$/
        [$2.to_i, $1.to_i]
      else
        [ 80, 24 ]
      end
    end

                              # *WARNING*:  This requires the external "stty" program!
    CHARACTER_MODE = "unix_stty"   # For Debugging purposes only.

    def raw_no_echo_mode
      @state = `stty -g`
      system "stty raw -echo -icanon isig"
    end

    def restore_mode
      system "stty #{@state}"
    end

    def get_character( input = STDIN )
      input.getbyte
    end

    def character_mode
      "unix_stty"
    end

    def get_line(question, highline, options={})
      if question.readline
        require "readline"    # load only if needed

        question_string = highline.render_statement(question)

        # prep auto-completion
        Readline.completion_proc = lambda do |string|
          question.selection.grep(/\A#{Regexp.escape(string)}/)
        end

        # work-around ugly readline() warnings
        old_verbose = $VERBOSE
        $VERBOSE    = nil
        raw_answer  = Readline.readline(question_string, true)
        if raw_answer.nil?
          if highline.track_eof?
            raise EOFError, "The input stream is exhausted."
          else
            raw_answer = String.new # Never return nil
          end
        end
        answer      = question.format_answer(raw_answer)
        $VERBOSE    = old_verbose

        answer
      else
        if highline.terminal.jruby? # This is "self" and will be removed soon.
          statement = highline.render_statement(question)
          raw_answer = @java_console.readLine(statement, nil)

          raise EOFError, "The input stream is exhausted." if raw_answer.nil? and
                                                              highline.track_eof?
        else
          raise EOFError, "The input stream is exhausted." if highline.track_eof? and
                                                              highline.input.eof?
          raw_answer = highline.input.gets
        end

        question.format_answer(raw_answer)
      end
    end
  end
end