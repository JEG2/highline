# tc_string_extension.rb
#
#  Created by Richard LeBer 2011-06-27
#
#  This is Free Software.  See LICENSE and COPYING for details.

require "test/unit"

require "highline"
require "stringio"
require "string_methods"

class TestStringExtension < Test::Unit::TestCase
  def setup
    HighLine.colorize_strings
    @string = "string"
  end

  include StringMethods
end
