require "minitest/autorun"
require "test_helper"

require "highline"

class TestHighLineWrapper < Minitest::Test
  def setup
    HighLine.reset
    @input    = StringIO.new
    @output   = StringIO.new
    @terminal = HighLine.new(@input, @output)
    @terminal.wrap_at = 80
  end

  def test_dont_wrap_if_line_is_shorter_than_wrap_at
    @terminal.say("This is a very short line.\n")
    assert_equal("This is a very short line.\n", @output.string)
  end

  def test_wrap_long_lines_correctly
    long_line =
      "This is a long flowing paragraph meant to span " +
      "several lines.  This text should definitely be " +
      "wrapped at the set limit, in the result.  Your code " +
      "does well with things like this.\n\n"

    wrapped_long_line =
      "This is a long flowing paragraph meant to span " +
      "several lines.  This text should\n" +

      "definitely be wrapped at the set limit, in the " +
      "result.  Your code does well with\n" +

      "things like this.\n\n"

    @terminal.say long_line
    assert_equal  wrapped_long_line, @output.string
  end

  def test_dont_wrap_already_well_wrapped_text
    well_formatted_text =
      "  * This is a simple embedded list.\n" +
      "  * You're code should not mess with this...\n" +
      "  * Because it's already formatted correctly and does not\n" +
      "    exceed the limit!\n"

    @terminal.say well_formatted_text
    assert_equal  well_formatted_text, @output.string
  end

  def test_wrap_single_word_longer_than_wrap_at
    @terminal.say("-=" * 50)
    assert_equal(("-=" * 40 + "\n") + ("-=" * 10 + "\n"), @output.string)
  end
end