#!/usr/bin/env ruby
# coding: utf-8

require "minitest/autorun"
require "test_helper"
require "highline/list"

class TestHighLineList < Minitest::Test
  def setup
    @items = [ "a", "b", "c", "d", "e", "f", "g", "h", "i", "j" ]
  end

  def test_in_2_cols
    list_in_two_cols =
      [ [ "a", "b" ],
        [ "c", "d" ],
        [ "e", "f" ],
        [ "g", "h" ],
        [ "i", "j" ] ]

    highline_list = HighLine::List.new(@items, cols: 2)

    assert_equal list_in_two_cols, highline_list.list
  end

  def test_in_2_cols_col_down
    col_down_list =
      [ [ "a", "f"],
        [ "b", "g"],
        [ "c", "h"],
        [ "d", "i"],
        [ "e", "j"] ]

    highline_list = HighLine::List.new(@items, cols: 2, col_down: true)

    assert_equal col_down_list, highline_list.list
  end

  def test_in_2_cols_transposed
    transposed_list =
      [ [ "a", "c", "e", "g", "i" ],
        [ "b", "d", "f", "h", "j" ] ]

    highline_list = HighLine::List.new(@items, cols: 2, transpose: true)

    assert_equal transposed_list, highline_list.list
  end

  def test_in_3_cols
    list_in_three_cols =
      [ [ "a", "b", "c" ],
        [ "d", "e", "f" ],
        [ "g", "h", "i" ],
        [ "j" ] ]

    highline_list = HighLine::List.new(@items, cols: 3)

    assert_equal list_in_three_cols, highline_list.list
  end
end