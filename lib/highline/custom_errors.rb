module HighLine::CustomErrors
  # Internal HighLine errors.
  class QuestionError < StandardError
  end

  class NotValidQuestionError < QuestionError
  end

  class NotInRangeQuestionError < QuestionError
  end

  class NoConfirmationQuestionError < QuestionError
  end

  class NoAutoCompleteMatch < StandardError
  end
end
