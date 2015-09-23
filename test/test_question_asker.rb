require "test_helper"

require_relative "../lib/highline.rb"
require_relative "../lib/highline/question_asker"
require_relative "../lib/highline/question"
require_relative "../lib/highline/statement"

require "stringio"

class TestQuestion < Minitest::Test

  def setup
    @question = HighLine::Question.new("How are you?", nil)
    @highline = HighLine.new

    @asker    = HighLine::QuestionAsker.new(@question, @highline)
  end

  def test_ask_once
    skip
    assert_equal "", @asker.ask_once
  end
end
