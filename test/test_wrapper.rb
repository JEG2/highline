require "minitest/autorun"
require "test_helper"

require "highline/wrapper"

class TestHighLineWrapper < Minitest::Test
  def setup
    @wrap_at = 80
  end

  def wrap(text)
    HighLine::Wrapper.wrap text, @wrap_at
  end

  def test_dont_wrap_if_line_is_shorter_than_wrap_at
    wrapped = wrap("This is a very short line.\n")
    assert_equal "This is a very short line.\n", wrapped
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

    wrapped = wrap(long_line)
    assert_equal wrapped_long_line, wrapped
  end

  def test_dont_wrap_already_well_wrapped_text
    well_formatted_text =
      "  * This is a simple embedded list.\n" +
      "  * You're code should not mess with this...\n" +
      "  * Because it's already formatted correctly and does not\n" +
      "    exceed the limit!\n"

    wrapped = wrap(well_formatted_text)
    assert_equal  well_formatted_text, wrapped
  end

  def test_wrap_single_word_longer_than_wrap_at
    wrapped = wrap("-=" * 50)
    assert_equal(("-=" * 40 + "\n") + ("-=" * 10), wrapped)
  end
end