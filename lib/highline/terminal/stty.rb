# coding: utf-8

class HighLine
	module SystemExtensions
		module Stty
                                # *WARNING*:  This requires the external "stty" program!
      CHARACTER_MODE = "stty"   # For Debugging purposes only.

      def raw_no_echo_mode
        @state = `stty -g`
        system "stty raw -echo -icanon isig"
      end

      def restore_mode
        system "stty #{@state}"
        print "\r"
      end
    end
  end
end