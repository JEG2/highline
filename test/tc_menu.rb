#!/usr/local/bin/ruby -w

# tc_menu.rb
#
#  Created by Gregory Thomas Brown on 2005-05-10.
#  Copyright 2005 smtose.org. All rights reserved.

$test_lib_dir ||= File.join(File.dirname(__FILE__), "..", "lib")
$:.unshift($test_lib_dir) unless $:.include?($test_lib_dir)

require "test/unit"

require "highline"
require "stringio"

class TestMenu < Test::Unit::TestCase
	def setup
		@input    = StringIO.new
		@output   = StringIO.new
		@terminal = HighLine.new(@input, @output)
	end

	def test_choices
		@input << "2\n"
		@input.rewind

		output = @terminal.choose do |menu|
			menu.choices("Sample1", "Sample2", "Sample3")
		end
		assert_equal("Sample2", output)
	end

	def test_display
		@input << "Sample1\n"
		@input.rewind

		@terminal.choose do |menu|
			menu.choice "Sample1" 
			menu.choice "Sample2" 
			menu.choice "Sample3" 
		end
		assert_equal("1. Sample1\n2. Sample2\n3. Sample3\n? ", @output.string)

		@output.truncate(@output.rewind)
		@input.rewind
		
		@terminal.choose do |menu|
			menu.index = :letter
			
			menu.choice "Sample1" 
			menu.choice "Sample2" 
			menu.choice "Sample3"
		end
		assert_equal("a. Sample1\nb. Sample2\nc. Sample3\n? ", @output.string)

		@output.truncate(@output.rewind)
		@input.rewind

		@terminal.choose do |menu|
			menu.index = :none

			menu.choice "Sample1" 
			menu.choice "Sample2" 
			menu.choice "Sample3"	
		end
		assert_equal("Sample1\nSample2\nSample3\n? ", @output.string)

		@output.truncate(@output.rewind)
		@input.rewind
		
		
		@terminal.choose do |menu|
			menu.index = "*"

			menu.choice "Sample1"
			menu.choice "Sample2"
			menu.choice "Sample3"
		end
		assert_equal("* Sample1\n* Sample2\n* Sample3\n? ", @output.string)
	end

	def test_flow
		@input << "Sample1\n"
		@input.rewind

		@terminal.choose do |menu|
			# Default: menu.flow = :rows
			
			menu.choice "Sample1" 
			menu.choice "Sample2" 
			menu.choice "Sample3" 
		end
		assert_equal("1. Sample1\n2. Sample2\n3. Sample3\n? ", @output.string)

		@output.truncate(@output.rewind)
		@input.rewind
		
		@terminal.choose do |menu|
			menu.flow = :columns_across
			
			menu.choice "Sample1" 
			menu.choice "Sample2" 
			menu.choice "Sample3"
		end
		assert_equal("1. Sample1  2. Sample2  3. Sample3\n? ", @output.string)

		@output.truncate(@output.rewind)
		@input.rewind

		@terminal.choose do |menu|
			menu.flow  = :inline
			menu.index = :none

			menu.choice "Sample1" 
			menu.choice "Sample2" 
			menu.choice "Sample3"	
		end
		assert_equal("Sample1, Sample2 or Sample3? ", @output.string)
	end

	def test_options
		@input << "Sample1\n2\n"
		@input.rewind
		
		selected = @terminal.choose do |menu|
			menu.choice "Sample1"
			menu.choice "Sample2"
			menu.choice "Sample3"
		end
		assert_equal("Sample1", selected)
		
		@input.rewind

		selected = @terminal.choose do |menu|
			menu.select_by = :index
			
			menu.choice "Sample1"
			menu.choice "Sample2"
			menu.choice "Sample3"
		end
		assert_equal("Sample2", selected)

		@input.rewind

		selected = @terminal.choose do |menu|
			menu.select_by = :name
			
			menu.choice "Sample1"
			menu.choice "Sample2"
			menu.choice "Sample3"
		end
		assert_equal("Sample1", selected)
	end

	def test_proc_out
		@input << "3\n3\n2\n"
		@input.rewind

		# Shows that by default proc results are not returned.
		output = @terminal.choose do |menu|
				menu.choice "Sample1" do "output1" end
				menu.choice "Sample2" do "output2" end
				menu.choice "Sample3" do "output3" end
		end
		assert_equal(nil, output)

		# Shows that they can be by setting proc_out to true.
		output = @terminal.choose do |menu|
				menu.proc_out = true
				menu.choice "Sample1" do "output1" end
				menu.choice "Sample2" do "output2" end
				menu.choice "Sample3" do "output3" end
		end
		assert_equal("output3", output)

		# Shows that a menu item without a proc will be returned no matter what.
		output = @terminal.choose do |menu|
			menu.choice "Sample1"
			menu.choice "Sample2"
			menu.choice "Sample3"
		end
		assert_equal("Sample2", output)
	end

	def test_simple_menu_shortcut
		@input << "3\n"
		@input.rewind

		selected = @terminal.choose(:save, :load, :quit)
		assert_equal(:quit, selected)
	end

	def test_select_by_letter
		@input << "b\n"
		@input.rewind
		

		selected = @terminal.choose do |menu| 
			menu.index = :letter
			menu.choice  :save
			menu.choice  :load
			menu.choice  :quit
		end
		assert_equal(:load, selected)
	end

	def test_symbols
		@input << "3\n"
		@input.rewind
		
		selected = @terminal.choose do |menu|
			menu.choices(:save, :load, :quit) 
		end
		assert_equal(:quit, selected)
	end
end
