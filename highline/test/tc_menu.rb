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

	def test_display
		
		@input << "Sample1\n"
		@input.rewind

		@terminal.choose do |menu|
			menu.choice "Sample1" do return end
			menu.choice "Sample2" do return end
			menu.choice "Sample3" do return end
			assert_equal("1. Sample1\n2. Sample2\n3. Sample3\n", menu.display)
			menu.index = :letter
			assert_equal("a. Sample1\nb. Sample2\nc. Sample3\n", menu.display)
			menu.index = :none
			assert_equal("- Sample1\n- Sample2\n- Sample3\n", menu.display)
		end
	end

	def test_options
		
		@input << "Sample1\n"
		@input.rewind
		
		@terminal.choose do |menu|
			menu.choice "Sample1" do return end
			menu.choice "Sample2" do return end
			menu.choice "Sample3" do return end
			assert_equal(["1","2","3","Sample1","Sample2","Sample3"],menu.options)
			menu.select_by = :index
			assert_equal(["1","2","3"],menu.options)
			menu.select_by = :name
			assert_equal(["Sample1","Sample2","Sample3"],menu.options)
		end

	end

	def test_choices
		@input << "2\n3\n"
		@input.rewind

		output = @terminal.choose do |menu|
			menu.choices("Sample1", "Sample2", "Sample3")
		end

		assert_equal("Sample2",output)

		#output = @terminal.choose do |menu|
		#	menu.proc_out = true
		#	menu.choices("Sample1", "Sample2", "Sample3") do |choice| "You selected " + choice end
		#end

		#assert_equal("You selected Sample3",output)
		
	end
		

	def test_proc_out

		@input << "3\n3\n2\n"
		@input.rewind

		#Shows that by default proc results are not returned
		output = @terminal.choose do |menu|
				menu.choice "Sample1" do "output1" end
				menu.choice "Sample2" do "output2" end
				menu.choice "Sample3" do "output3" end
		end
		assert_equal(nil,output)

		#Shows that they can be by setting proc_out to true
		output = @terminal.choose do |menu|
				menu.proc_out = true
				menu.choice "Sample1" do "output1" end
				menu.choice "Sample2" do "output2" end
				menu.choice "Sample3" do "output3" end
		end
		assert_equal("output3",output)

		#Shows that a menu item without a proc will be returned no matter what
		output = @terminal.choose do |menu|
			menu.choice "Sample1"
			menu.choice "Sample2"
			menu.choice "Sample3"
		end
		assert_equal("Sample2",output)

		
	end
				
end

	
		
