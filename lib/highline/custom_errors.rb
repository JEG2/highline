class HighLine

  # Internal HighLine errors.
  module CustomErrors
    class ExplainableError < StandardError
    end

    class QuestionError < ExplainableError
      def explanation_key
        nil
      end
    end

    class NotValidQuestionError < ExplainableError
      def explanation_key
        :not_valid
      end
    end

    class NotInRangeQuestionError < ExplainableError
      def explanation_key
        :not_in_range
      end
    end

    class NoConfirmationQuestionError < ExplainableError
      def explanation_key
        nil
      end
    end

    class NoAutoCompleteMatch < ExplainableError
      def explanation_key
        :no_completion
      end
    end
  end
end
