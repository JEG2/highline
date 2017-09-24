# encoding: utf-8

require "test_helper"

class TestQuestion < Minitest::Test
  def setup
    @input    = StringIO.new
    @output   = StringIO.new
    @highline = HighLine.new(@input, @output)

    @question = HighLine::Question.new("How are you?", nil)
    @asker    = HighLine::QuestionAsker.new(@question, @highline)
  end

  def test_ask_once
    answer = "Very good, thanks for asking!"

    @input.string = answer

    assert_equal answer, @asker.ask_once
  end
end
