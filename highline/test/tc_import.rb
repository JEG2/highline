#!/usr/local/bin/ruby -w

# tc_import.rb
#
#  Created by James Edward Gray II on 2005-04-26.
#  Copyright 2005 Gray Productions. All rights reserved.

require "test/unit"

require "highline/import"
require "stringio"

class TestImport < Test::Unit::TestCase
	def test_import
		assert_respond_to(self, :agree)
		assert_respond_to(self, :ask)
		assert_respond_to(self, :choose)
		assert_respond_to(self, :say)
	end
	
	def test_redirection
		$terminal = HighLine.new(nil, (output = StringIO.new))
		say("Testing...")
		assert_equal("Testing...\n", output.string)
	end
end
