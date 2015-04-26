class HighLine
  module SystemExtensions
    module UnixStty
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
    end
  end
end