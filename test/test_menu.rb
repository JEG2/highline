#!/usr/bin/env ruby
# coding: utf-8

# tc_menu.rb
#
#  Created by Gregory Thomas Brown on 2005-05-10.
#  Copyright 2005. All rights reserved.
#
#  This is Free Software. See LICENSE and COPYING for details.

require "test_helper"

require "highline"
require "stringio"

class TestMenu < Minitest::Test
  def setup
    HighLine.reset
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

  def test_flow
    @input << "Sample1\n"
    @input.rewind

    @terminal.choose do |menu|
      # Default:  menu.flow = :rows

      menu.choice "Sample1"
      menu.choice "Sample2"
      menu.choice "Sample3"
    end
    assert_equal("1. Sample1\n2. Sample2\n3. Sample3\n?  ", @output.string)

    @output.truncate(@output.rewind)
    @input.rewind

    @terminal.choose do |menu|
      menu.flow = :columns_across

      menu.choice "Sample1"
      menu.choice "Sample2"
      menu.choice "Sample3"
    end
    assert_equal("1. Sample1  2. Sample2  3. Sample3\n?  ", @output.string)

    @output.truncate(@output.rewind)
    @input.rewind

    @terminal.choose do |menu|
      menu.flow  = :inline
      menu.index = :none

      menu.choice "Sample1"
      menu.choice "Sample2"
      menu.choice "Sample3"
    end
    assert_equal("Sample1, Sample2 or Sample3?  ", @output.string)
  end

  def test_unicode_flow
    @input << "1\n"
    @input.rewind

    @terminal.choose do |menu|
      # Default:  menu.flow = :rows
      menu.choice "Unicode right single quotation mark: ’"
    end
    assert_equal("1. Unicode right single quotation mark: ’\n?  ".encode(@output.external_encoding, { :undef => :replace }), @output.string)
  end

  def test_text_override_index_selects_name
    @input << "1\n"
    @input.rewind

    selected = @terminal.choose do |menu|
      item1 = HighLine::Menu::MenuItem.new(name: "Sample1", text: "Sample2")
      item2 = HighLine::Menu::MenuItem.new(name: "Sample2", text: "Sample1")
      menu.choice(item1)
      menu.choice(item2)
    end
    assert_equal(selected, "Sample1")
    assert_equal("1. Sample2\n" +
                 "2. Sample1\n" +
                 "?  ", @output.string)
  end

  def test_text_override_selections_matches_name
    @input << "Sample2\n"
    @input.rewind

    selected = @terminal.choose do |menu|
      item1 = HighLine::Menu::MenuItem.new(name: "Sample1", text: "Sample2")
      item2 = HighLine::Menu::MenuItem.new(name: "Sample2", text: "Sample1")
      menu.choice(item1)
      menu.choice(item2)
    end
    assert_equal(selected, "Sample2")
    assert_equal("1. Sample2\n" +
                 "2. Sample1\n" +
                 "?  ", @output.string)
  end

  def test_menu_item_index_selects_name
    @input << "1\n"
    @input.rewind

    selected = @terminal.choose do |menu|
      menu.add_item(HighLine::Menu::MenuItem.new(name: "Sample1", text: "Sample2"))
      menu.add_item(HighLine::Menu::MenuItem.new(name: "Sample2", text: "Sample1"))
    end
    assert_equal(selected, "Sample1")
    assert_equal("1. Sample2\n" +
                 "2. Sample1\n" +
                 "?  ", @output.string)
  end

  def test_menu_item_selections_matches_name
    @input << "Sample2\n"
    @input.rewind

    selected = @terminal.choose do |menu|
      menu.add_item(HighLine::Menu::MenuItem.new(name: "Sample1", text: "Sample2"))
      menu.add_item(HighLine::Menu::MenuItem.new(name: "Sample2", text: "Sample1"))
    end
    assert_equal(selected, "Sample2")
    assert_equal("1. Sample2\n" +
                 "2. Sample1\n" +
                 "?  ", @output.string)
  end

  def test_help
    @input << "help\nhelp load\nhelp rules\nhelp missing\n"
    @input.rewind

    4.times do
      @terminal.choose do |menu|
        menu.shell = true

        menu.choice(:load, "Load a file.")
        menu.choice(:save, "Save data in file.")
        menu.choice(:quit, "Exit program.")

        menu.help("rules", "The rules of this system are as follows...")
      end
    end
    assert_equal( "1. load\n2. save\n3. quit\n4. help\n?  " +
                  "This command will display helpful messages about " +
                  "functionality, like this one.  To see the help for a " +
                  "specific topic enter:\n" +
                  "\thelp [TOPIC]\n" +
                  "Try asking for help on any of the following:\n" +
                  "\nload   quit   rules  save \n" +
                  "1. load\n2. save\n3. quit\n4. help\n?  " +
                  "= load\n\n" +
                  "Load a file.\n" +
                  "1. load\n2. save\n3. quit\n4. help\n?  " +
                  "= rules\n\n" +
                  "The rules of this system are as follows...\n" +
                  "1. load\n2. save\n3. quit\n4. help\n?  " +
                  "= missing\n\n" +
                  "There's no help for that topic.\n", @output.string )
  end

  def test_index
    @input << "Sample1\n"
    @input.rewind

    @terminal.choose do |menu|
      # Default:  menu.index = :number

      menu.choice "Sample1"
      menu.choice "Sample2"
      menu.choice "Sample3"
    end
    assert_equal("1. Sample1\n2. Sample2\n3. Sample3\n?  ", @output.string)

    @output.truncate(@output.rewind)
    @input.rewind

    @terminal.choose do |menu|
      menu.index        = :letter
      menu.index_suffix = ") "

      menu.choice "Sample1"
      menu.choice "Sample2"
      menu.choice "Sample3"
    end
    assert_equal("a) Sample1\nb) Sample2\nc) Sample3\n?  ", @output.string)

    @output.truncate(@output.rewind)
    @input.rewind

    @terminal.choose do |menu|
      menu.index = :none

      menu.choice "Sample1"
      menu.choice "Sample2"
      menu.choice "Sample3"
    end
    assert_equal("Sample1\nSample2\nSample3\n?  ", @output.string)

    @output.truncate(@output.rewind)
    @input.rewind

    @terminal.choose do |menu|
      menu.index        = "*"

      menu.choice "Sample1"
      menu.choice "Sample2"
      menu.choice "Sample3"
    end
    assert_equal("* Sample1\n* Sample2\n* Sample3\n?  ", @output.string)
  end

  def test_layouts
    @input << "save\n"
    @input.rewind

    @terminal.choose(:load, :save, :quit) # Default:  layout = :list
    assert_equal("1. load\n2. save\n3. quit\n?  ", @output.string)

    @input.rewind
    @output.truncate(@output.rewind)

    @terminal.choose(:load, :save, :quit) do |menu|
      menu.header = "File Menu"
    end
    assert_equal( "File Menu:\n" +
                  "1. load\n2. save\n3. quit\n?  ", @output.string )

    @input.rewind
    @output.truncate(@output.rewind)

    @terminal.choose(:load, :save, :quit) do |menu|
      menu.layout = :one_line
      menu.header = "File Menu"
      menu.prompt = "Operation?  "
    end
    assert_equal( "File Menu:  Operation?  " +
                  "(load, save or quit)  ", @output.string )

    @input.rewind
    @output.truncate(@output.rewind)

    @terminal.choose(:load, :save, :quit) do |menu|
      menu.layout   = :menu_only
    end
    assert_equal("load, save or quit?  ", @output.string)

    @input.rewind
    @output.truncate(@output.rewind)

    @terminal.choose(:load, :save, :quit) do |menu|
      menu.layout = '<%= list(menu) %>File Menu:  '
    end
    assert_equal("1. load\n2. save\n3. quit\nFile Menu:  ", @output.string)
  end

  def test_list_option
    @input << "l\n"
    @input.rewind

    @terminal.choose(:load, :save, :quit) do |menu|
      menu.layout      = :menu_only
      menu.list_option = ", or "
    end
    assert_equal("load, save, or quit?  ", @output.string)
  end

  def test_nil_on_handled
    @input << "3\n3\n2\n"
    @input.rewind

    # Shows that by default proc results are returned.
    output = @terminal.choose do |menu|
        menu.choice "Sample1" do "output1" end
        menu.choice "Sample2" do "output2" end
        menu.choice "Sample3" do "output3" end
    end
    assert_equal("output3", output)

    #
    # Shows that they can be replaced with +nil+ by setting
    # _nil_on_handled to +true+.
    #
    output = @terminal.choose do |menu|
        menu.nil_on_handled = true
        menu.choice "Sample1" do "output1" end
        menu.choice "Sample2" do "output2" end
        menu.choice "Sample3" do "output3" end
    end
    assert_equal(nil, output)

    # Shows that a menu item without a proc will be returned no matter what.
    output = @terminal.choose do |menu|
      menu.choice "Sample1"
      menu.choice "Sample2"
      menu.choice "Sample3"
    end
    assert_equal("Sample2", output)
  end

  def test_passed_command
    @input << "q\n"
    @input.rewind

    selected = nil
    @terminal.choose do |menu|
      menu.choices(:load, :save, :quit) { |command| selected = command }
    end
    assert_equal(:quit, selected)
  end

  def test_question_options
    @input << "save\n"
    @input.rewind

    answer = @terminal.choose(:Load, :Save, :Quit) do |menu|
      menu.case = :capitalize
    end
    assert_equal(:Save, answer)

    @input.rewind

    answer = @terminal.choose(:Load, :Save, :Quit) do |menu|
      menu.case      = :capitalize
      menu.character = :getc
    end
    assert_equal(:Save, answer)
    assert_equal(?a, @input.getc)
  end

  def test_select_by
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

  def test_hidden
    @input << "Hidden\n4\n"
    @input.rewind

    selected = @terminal.choose do |menu|
      menu.choice "Sample1"
      menu.choice "Sample2"
      menu.choice "Sample3"
      menu.hidden "Hidden!"
    end
    assert_equal("Hidden!", selected)
    assert_equal("1. Sample1\n2. Sample2\n3. Sample3\n?  ", @output.string)

    @input.rewind

    selected = @terminal.choose do |menu|
      menu.select_by = :index

      menu.choice "Sample1"
      menu.choice "Sample2"
      menu.choice "Sample3"
      menu.hidden "Hidden!"
    end
    assert_equal("Hidden!", selected)

    @input.rewind

    selected = @terminal.choose do |menu|
      menu.select_by = :name

      menu.choice "Sample1"
      menu.choice "Sample2"
      menu.choice "Sample3"
      menu.hidden "Hidden!"
    end
    assert_equal("Hidden!", selected)

    @input.rewind
  end

  def test_select_by_letter
    @input << "b\n"
    @input.rewind

    selected = @terminal.choose do |menu|
      menu.index  = :letter
      menu.choice   :save
      menu.choice   :load
      menu.choice   :quit
    end
    assert_equal(:load, selected)
  end

  def test_shell
    @input << "save --some-option my_file.txt\n"
    @input.rewind

    selected = nil
    options  = nil
    answer = @terminal.choose do |menu|
      menu.choices(:load, :quit)
      menu.choice(:save) do |command, details|
        selected = command
        options  = details

        "Saved!"
      end
      menu.shell = true
    end
    assert_equal("Saved!", answer)
    assert_equal(:save, selected)
    assert_equal("--some-option my_file.txt", options)
  end

  def test_simple_menu_shortcut
    @input << "3\n"
    @input.rewind

    selected = @terminal.choose(:save, :load, :quit)
    assert_equal(:quit, selected)
  end

  def test_symbols
    @input << "3\n"
    @input.rewind

    selected = @terminal.choose do |menu|
      menu.choices(:save, :load, :quit)
    end
    assert_equal(:quit, selected)
  end

  def test_paged_print_infinite_loop_bug
    @terminal.page_at = 5
    # Will page twice, so start with two new lines
    @input << "\n\n3\n"
    @input.rewind

    # Sadly this goes into an infinite loop without the fix to page_print
    selected = @terminal.choose(* 1..10)
    assert_equal(selected, 3)
  end

  def test_cancel_paging
    # Tests that paging can be cancelled halfway through
    @terminal.page_at = 5
    # Will page twice, so stop after first page and make choice 3
    @input << "q3\n"
    @input.rewind

    selected = @terminal.choose(* 1..10)
    assert_equal(selected, 3)

    # Make sure paging message appeared
    assert( @output.string.index('press enter/return to continue or q to stop'),
            "Paging message did not appear." )

    # Make sure it only appeared once
    assert( @output.string !~ /q to stop.*q to stop/m,
            "Paging message appeared more than once." )
  end

  def test_autocomplete_prompt
    @input << "lisp\nRuby\n"
    @input.rewind

    answer = @terminal.choose do |menu|
      menu.choice(:Perl)
      menu.choice(:Python)
      menu.choice(:Ruby)
      menu.prompt = "What is your favorite programming language?  "
    end
    languages = [:Perl, :Python, :Ruby]
    assert_equal("1. Perl\n" +
                 "2. Python\n" +
                 "3. Ruby\n" +
                 "What is your favorite programming language?  " +
                  "You must choose one of [1, 2, 3, Perl, Python, Ruby].\n" +
                  "?  ", @output.string )
  end

  # Issue #180 - https://github.com/JEG2/highline/issues/180
  def test_menu_prompt
    @input << "2\n1\n"
    @input.rewind

    selected = @terminal.choose do |menu|
      menu.responses[:ask_on_error] = "> "
      menu.prompt = "> "
      menu.choice :exit, "Exit cube editor"
    end

    prompt = "> "
    first_asking = "1. exit\n"
    error_message = "You must choose one of [1, exit].\n"
    complete_interaction = first_asking + prompt + error_message + prompt # Same prompt when repeating question

    assert_equal complete_interaction, @output.string
  end

  def test_menu_gather_integer
    @input << "Sample1\nlast\n"
    @input.rewind

    selected = @terminal.choose do |menu|
      menu.gather = 2
      menu.choice "Sample1"
      menu.choice "Sample2"
      menu.choice "last"
    end
    assert_equal(["Sample1", "last"], selected)

    assert_equal("1. Sample1\n" +
                 "2. Sample2\n" +
                 "3. last\n" +
                 "?  1. Sample1\n" +
                 "2. Sample2\n" +
                 "3. last\n" +
                 "?  ", @output.string)
  end

  def test_menu_gather_string
    @input << "Sample1\nlast\n"
    @input.rewind

    selected = @terminal.choose do |menu|
      menu.gather = :last
      menu.choice "Sample1"
      menu.choice "Sample2"
      menu.choice :last
    end
    assert_equal(["Sample1"], selected)

    assert_equal("1. Sample1\n" +
                 "2. Sample2\n" +
                 "3. last\n" +
                 "?  1. Sample1\n" +
                 "2. Sample2\n" +
                 "3. last\n" +
                 "?  ", @output.string)
  end

  def test_menu_gather_symbol
    @input << "Sample1\nlast\n"
    @input.rewind

    selected = @terminal.choose do |menu|
      menu.gather = "last"
      menu.choice "Sample1"
      menu.choice "Sample2"
      menu.choice "last"
    end
    assert_equal(["Sample1"], selected)

    assert_equal("1. Sample1\n" +
                 "2. Sample2\n" +
                 "3. last\n" +
                 "?  1. Sample1\n" +
                 "2. Sample2\n" +
                 "3. last\n" +
                 "?  ", @output.string)
  end

  def test_menu_gather_regexp
    @input << "Sample1\nlast\n"
    @input.rewind

    selected = @terminal.choose do |menu|
      menu.gather = /la/
      menu.choice "Sample1"
      menu.choice "Sample2"
      menu.choice "last"
    end
    assert_equal(["Sample1"], selected)

    assert_equal("1. Sample1\n" +
                 "2. Sample2\n" +
                 "3. last\n" +
                 "?  1. Sample1\n" +
                 "2. Sample2\n" +
                 "3. last\n" +
                 "?  ", @output.string)
  end

  def test_menu_gather_hash
    @input << "Sample1\n3\n"
    @input.rewind

    selected = @terminal.choose do |menu|
      menu.gather = { "First" => true, second: true }
      menu.choice "Sample1"
      menu.choice "Sample2"
      menu.choice "last"
    end
    assert_equal({ "First" => "Sample1", second: "last" }, selected)

    assert_equal("1. Sample1\n" +
                 "2. Sample2\n" +
                 "3. last\n" +
                 "?  1. Sample1\n" +
                 "2. Sample2\n" +
                 "3. last\n" +
                 "?  ", @output.string)
  end
end
