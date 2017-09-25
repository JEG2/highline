#!/usr/bin/env ruby
# coding: utf-8

require "test_helper"

require "highline/list"

class TestHighLineList < Minitest::Test
  def setup
    @items = %w[a b c d e f g h i j]
  end

  def test_in_2_cols
    list_in_two_cols =
      [%w[a b],
       %w[c d],
       %w[e f],
       %w[g h],
       %w[i j]]

    highline_list = HighLine::List.new(@items, cols: 2)

    assert_equal list_in_two_cols, highline_list.list
  end

  def test_in_2_cols_col_down
    col_down_list =
      [%w[a f],
       %w[b g],
       %w[c h],
       %w[d i],
       %w[e j]]

    highline_list = HighLine::List.new(@items, cols: 2, col_down: true)

    assert_equal col_down_list, highline_list.list
  end

  def test_in_2_cols_transposed
    transposed_list =
      [%w[a c e g i],
       %w[b d f h j]]

    highline_list = HighLine::List.new(@items, cols: 2, transpose: true)

    assert_equal transposed_list, highline_list.list
  end

  def test_in_3_cols
    list_in_three_cols =
      [%w[a b c],
       %w[d e f],
       %w[g h i],
       ["j"]]

    highline_list = HighLine::List.new(@items, cols: 3)

    assert_equal list_in_three_cols, highline_list.list
  end
end
