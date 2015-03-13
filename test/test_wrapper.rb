require "minitest/autorun"
require "test_helper"

class TestHighLine < Minitest::Test
  def setup
    HighLine.reset
    @input    = StringIO.new
    @output   = StringIO.new
    @terminal = HighLine.new(@input, @output)
  end

  def test_wrap
    @terminal.wrap_at = 80

    @terminal.say("This is a very short line.")
    assert_equal("This is a very short line.\n", @output.string)

    @output.truncate(@output.rewind)

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

    @output.truncate(@output.rewind)

    well_formatted_text =
      "  * This is a simple embedded list.\n" +
      "  * You're code should not mess with this...\n" +
      "  * Because it's already formatted correctly and does not\n" +
      "    exceed the limit!\n"

    @terminal.say well_formatted_text
    assert_equal  well_formatted_text, @output.string

    @output.truncate(@output.rewind)

    @terminal.say("-=" * 50)
    assert_equal(("-=" * 40 + "\n") + ("-=" * 10 + "\n"), @output.string)
  end
end