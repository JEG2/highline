#!/usr/bin/env ruby
# coding: utf-8

require "test_helper"

require "highline/question"

class TestAnswerConverter < Minitest::Test
  def test_integer_convertion
    question = HighLine::Question.new("What's your age?", Integer)
    question.answer = "18"
    answer_converter = HighLine::Question::AnswerConverter.new(question)

    refute_equal "18", answer_converter.convert
    assert_equal   18, answer_converter.convert
  end

  def test_float_convertion
    question = HighLine::Question.new("Write PI", Float)
    question.answer = "3.14159"
    answer_converter = HighLine::Question::AnswerConverter.new(question)

    refute_equal "3.14159", answer_converter.convert
    assert_equal   3.14159, answer_converter.convert
  end
end