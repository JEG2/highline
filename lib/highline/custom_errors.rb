class HighLine

  # Internal HighLine errors.
  module CustomErrors
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
end
