# coding: utf-8

class HighLine
  class Terminal
    # HighLine::Terminal option that uses external "stty" program
    # to control terminal options.
    class UnixStty < Terminal

      # A Unix savvy method using stty to fetch the console columns, and rows.
      # ... stty does not work in JRuby
      # @return (see Terminal#terminal_size)
      def terminal_size
        begin
          require "io/console"
          winsize = IO.console.winsize.reverse rescue nil
          return winsize if winsize
        rescue LoadError
        end

        if /solaris/ =~ RUBY_PLATFORM and
          `stty` =~ /\brows = (\d+).*\bcolumns = (\d+)/
          [$2, $1].map { |x| x.to_i }
        elsif `stty size` =~ /^(\d+)\s(\d+)$/
          [$2.to_i, $1.to_i]
        else
          [ 80, 24 ]
        end
      end

      # (see Terminal#raw_no_echo_mode)
      def raw_no_echo_mode
        @state = `stty -g`
        system "stty raw -echo -icanon isig"
      end

      # (see Terminal#restore_mode)
      def restore_mode
        system "stty #{@state}"
        print "\r"
      end

      # (see Terminal#get_character)
      def get_character( input = STDIN )
        input.getc
      end
    end
  end
end