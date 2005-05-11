
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

	def test_sample
		@input << "Sample1\n"
		@input.rewind
		
		choice = @terminal.choose do |menu|
			  menu.add "Sample1" do return end
			  menu.add "Sample2" do return end
			  menu.add "Sample3" do return end
		end

		assert_equal("Sample1",choice.name)
		
	end

	def test_display
		
		@input << "Sample1\n"
		@input.rewind

		@terminal.choose do |menu|
			menu.add "Sample1" do return end
			menu.add "Sample2" do return end
			menu.add "Sample3" do return end
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
			menu.add "Sample1" do return end
			menu.add "Sample2" do return end
			menu.add "Sample3" do return end
			assert_equal(["1","2","3","Sample1","Sample2","Sample3"],menu.options)
			menu.select_by = :index
			assert_equal(["1","2","3"],menu.options)
			menu.select_by = :name
			assert_equal(["Sample1","Sample2","Sample3"],menu.options)
		end

	end
		
		
		


end

	
		
