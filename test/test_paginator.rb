require "minitest/autorun"
require "test_helper"

require "highline"

class TestHighLinePaginator < Minitest::Test
  def setup
    HighLine.reset
    @input    = StringIO.new
    @output   = StringIO.new
    @terminal = HighLine.new(@input, @output)
  end

  def test_paging
    @terminal.page_at = 22

    @input << "\n\n"
    @input.rewind

    @terminal.say((1..50).map { |n| "This is line #{n}.\n"}.join)
    assert_equal( (1..22).map { |n| "This is line #{n}.\n"}.join +
                  "\n-- press enter/return to continue or q to stop -- \n\n" +
                  (23..44).map { |n| "This is line #{n}.\n"}.join +
                  "\n-- press enter/return to continue or q to stop -- \n\n" +
                  (45..50).map { |n| "This is line #{n}.\n"}.join,
                  @output.string )
  end
end