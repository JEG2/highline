#!/usr/local/bin/ruby -w

# tc_highline.rb
#
#  Created by Richard LeBer 2011-06-27
#
#  This is Free Software.  See LICENSE and COPYING for details.

require "test/unit"

require "highline"
require "stringio"

# if HighLine::CHARACTER_MODE == "Win32API"
#   class HighLine
#     # Override Windows' character reading so it's not tied to STDIN.
#     def get_character( input = STDIN )
#       input.getc
#     end
#   end
# end

class TestStringExtensions < Test::Unit::TestCase
  def setup
    @input    = StringIO.new
    @output   = StringIO.new
    @terminal = HighLine.new(@input, @output)  
  end
end
