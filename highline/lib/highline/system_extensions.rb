#!/usr/local/bin/ruby -w

# import.rb
#
#  Created by James Edward Gray II on 2006-06-14.
#  Copyright 2006 Gray Productions. All rights reserved.
#
#  This is Free Software.  See LICENSE and COPYING for details

class HighLine
  module SystemExtensions
    #
    # This section builds a character reading function to suit the proper
    # platform we're running on.  Be warned:  Here be dragons!
    #
    begin
      require "Win32API"       # See if we're on Windows.

      CHARACTER_MODE = "Win32API"    # For Debugging purposes only.

      #
      # Windows savvy getc().
      # 
      # *WARNING*:  This method ignores <tt>@input</tt> and reads one
      # character from +STDIN+!
      # 
      def get_character( input = STDIN )
        Win32API.new("crtdll", "_getch", [ ], "L").Call
      end
    rescue LoadError             # If we're not on Windows try...
      begin
        require "termios"    # Unix, first choice.

        CHARACTER_MODE = "termios"    # For Debugging purposes only.

        #
        # Unix savvy getc().  (First choice.)
        # 
        # *WARNING*:  This method requires the "termios" library!
        # 
        def get_character( input = STDIN )
          old_settings = Termios.getattr(input)

          new_settings         =  old_settings.dup
          new_settings.c_lflag &= ~(Termios::ECHO | Termios::ICANON)

          begin
            Termios.setattr(input, Termios::TCSANOW, new_settings)
            input.getc
          ensure
            Termios.setattr(input, Termios::TCSANOW, old_settings)
          end
        end
      rescue LoadError         # If our first choice fails, default.
        CHARACTER_MODE = "stty"    # For Debugging purposes only.

        #
        # Unix savvy getc().  (Second choice.)
        # 
        # *WARNING*:  This method requires the external "stty" program!
        # 
        def get_character( input = STDIN )
          state = `stty -g`

          begin
            system "stty raw -echo cbreak"
            input.getc
          ensure
            system "stty #{state}"
          end
        end
      end
    end
  end
end
