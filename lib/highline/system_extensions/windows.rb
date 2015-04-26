#!/usr/bin/env ruby
#coding: utf-8

class HighLine
  module SystemExtensions
    module Windows
      CHARACTER_MODE = "Win32API"    # For Debugging purposes only.

      #
      # Windows savvy getc().
      #
      # *WARNING*:  This method ignores <tt>input</tt> and reads one
      # character from +STDIN+!
      #
      def get_character( input = STDIN )
        WinAPI._getch
      end

      # We do not define a raw_no_echo_mode for Windows as _getch turns off echo
      def raw_no_echo_mode
      end

      def restore_mode
      end

      # A Windows savvy method to fetch the console columns, and rows.
      def terminal_size
        format        = 'SSSSSssssSS'
        buf           = ([0] * format.size).pack(format)
        stdout_handle = WinAPI.GetStdHandle(0xFFFFFFF5)

        WinAPI.GetConsoleScreenBufferInfo(stdout_handle, buf)
        _, _, _, _, _,
        left, top, right, bottom, _, _ = buf.unpack(format)
        return right - left + 1, bottom - top + 1
      end
    end
  end
end
