require "test_helper"

require_relative "../lib/highline/question_asker"

class TestQuestion < Minitest::Test
  def setup
    @highline = HighLine.new

    @question = HighLine::Question.new("How are you?", nil)
    @asker    = HighLine::QuestionAsker.new(@question, @highline)
  end

  def test_ask_once
    skip
    assert_equal "", @asker.ask_once
  end
end
