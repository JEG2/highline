class HighLine

  # Internal HighLine errors.
  module CustomErrors
    class QuestionError < StandardError
    end

    class NotValidQuestionError < QuestionError
      def explanation_key
        :not_valid
      end
    end

    class NotInRangeQuestionError < QuestionError
      def explanation_key
        :not_in_range
      end
    end

    class NoConfirmationQuestionError < QuestionError
      def explanation_key
        nil
      end
    end

    class NoAutoCompleteMatch < StandardError
      def explanation_key
        :no_completion
      end
    end
  end
end
