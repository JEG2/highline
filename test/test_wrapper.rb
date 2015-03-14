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

  def test_wrap_plain_text
    line = "123 567 901 345"

    1.upto(25) do |wrap_at|
      wrapped = HighLine::Wrapper.wrap(line, wrap_at)

      case wrap_at
      when 1
        assert_equal "1\n2\n3\n5\n6\n7\n9\n0\n1\n3\n4\n5", wrapped
      when 2
        assert_equal "12\n3\n56\n7\n90\n1\n34\n5", wrapped
      when 3..6
        assert_equal "123\n567\n901\n345", wrapped
      when 7..10
        assert_equal "123 567\n901 345", wrapped
      when 11..14
        assert_equal "123 567 901\n345", wrapped
      when 15..25
        assert_equal "123 567 901 345", wrapped
      end
    end
  end

  def test_wrap_whole_colored_text
    skip "TODO: Implement whole colored text wrapping!"
    line = "\e[31m123 567 901 345\e[0m"

    1.upto(25) do |wrap_at|
      wrapped = HighLine::Wrapper.wrap(line, wrap_at)

      case wrap_at
      when 1
        assert_equal "\e[31m1\n2\n3\n5\n6\n7\n9\n0\n1\n3\n4\n5\e[0m", wrapped
      when 2
        assert_equal "\e[31m12\n3\n56\n7\n90\n1\n34\n5\e[0m", wrapped
      when 3..6
        assert_equal "\e[31m123\n567\n901\n345\e[0m", wrapped
      when 7..10
        assert_equal "\e[31m123 567\n901 345\e[0m", wrapped
      when 11..14
        assert_equal "\e[31m123 567 901\n345\e[0m", wrapped
      when 15..25
        assert_equal "\e[31m123 567 901 345\e[0m", wrapped
      end
    end
  end

  def test_wrap_partially_colored_text
    skip "TODO: Implement middle colored text wrapping!"
    line = "123 567 \e[31m901\e[0m 345"

    1.upto(25) do |wrap_at|
      wrapped = HighLine::Wrapper.wrap(line, wrap_at)

      case wrap_at
      when 1
        assert_equal "1\n2\n3\n5\n6\n7\n\e[31m9\n0\n1\e[0m\n3\n4\n5", wrapped
      when 2
        assert_equal "12\n3\n56\n7\n\e[31m90\n1\e[0m\n34\n5", wrapped
      when 3..6
        assert_equal "123\n567\n\e[31m901\e[0m\n345", wrapped
      when 7..10
        assert_equal "123 567\n\e[31m901\e[0m 345", wrapped
      when 11..14
        assert_equal "123 567 \e[31m901\e[0m\n345", wrapped
      when 15..25
        assert_equal "123 567 \e[31m901\e[0m 345", wrapped
      end
    end
  end

  def test_wrap_text_with_partially_colored_word_in_the_middle
    skip "TODO: Implement middle partially colored text wrapping!"
    line = "123 567 9\e[31m0\e[0m1 345"

    1.upto(25) do |wrap_at|
      wrapped = HighLine::Wrapper.wrap(line, wrap_at)

      case wrap_at
      when 1
        assert_equal "1\n2\n3\n5\n6\n7\n9\n\e[31m0\e[0m\n1\n3\n4\n5", wrapped
      when 2
        assert_equal "12\n3\n56\n7\n9\e[31m0\e[0m\n1\n34\n5", wrapped
      when 3..6
        assert_equal "123\n567\n9\e[31m0\e[0m1\n345", wrapped
      when 7..10
        assert_equal "123 567\n9\e[31m0\e[0m1 345", wrapped
      when 11..14
        assert_equal "123 567 9\e[31m0\e[0m1\n345", wrapped
      when 15..25
        assert_equal "123 567 9\e[31m0\e[0m1 345", wrapped
      end
    end
  end
end