class HighLine
  class QuestionAsker
    attr_reader :question

    include CustomErrors

    def initialize(question, highline)
      @question = question
      @highline = highline
    end

    #
    # Gets just one answer, as opposed to #gather_answers
    #
    def ask_once
      question.show_question(@highline)

      begin
        question.get_response_or_default(@highline)
        raise NotValidQuestionError unless question.valid_answer?

        question.convert

        if question.confirm
          raise NoConfirmationQuestionError unless @highline.send(:confirm, question)
        end

      rescue NoConfirmationQuestionError
        explain_error(nil)
        retry

      rescue NotInRangeQuestionError
        explain_error(:not_in_range)
        retry

      rescue NotValidQuestionError
        explain_error(:not_valid)
        retry

      rescue QuestionError
        retry

      rescue ArgumentError => error
        case error.message
        when /ambiguous/
          # the assumption here is that OptionParser::Completion#complete
          # (used for ambiguity resolution) throws exceptions containing
          # the word 'ambiguous' whenever resolution fails
          explain_error(:ambiguous_completion)
          retry
        when /invalid value for/
          explain_error(:invalid_type)
          retry
        else
          raise
        end

      rescue NoAutoCompleteMatch
        explain_error(:no_completion)
        retry
      end
      question.answer
    end

    ## Multiple questions

    #
    # Collects an Array/Hash full of answers as described in
    # HighLine::Question.gather().
    #
    def gather_answers
      original_question_template = question.template
      verify_match = question.verify_match

      begin   # when verify_match is set this loop will repeat until unique_answers == 1
        question.template = original_question_template

        answers =
        case question.gather
        when Integer
          gather_integer
        when ::String, Regexp
          gather_regexp
        when Hash
          gather_hash
        end

        if verify_match && (@highline.send(:unique_answers, answers).size > 1)
          explain_error(:mismatch)
        else
          verify_match = false
        end

      end while verify_match

      question.verify_match ? @highline.send(:last_answer, answers) : answers
    end

    def gather_integer
      answers = []

      answers << ask_once

      question.template = ""

      (question.gather-1).times do
        answers  << ask_once
      end

      answers
    end

    def gather_regexp
      answers = []

      answers << ask_once

      question.template = ""
      until (question.gather.is_a?(::String) && answers.last.to_s == question.gather) ||
            (question.gather.is_a?(Regexp)   && answers.last.to_s =~ question.gather)
        answers  << ask_once
      end

      answers.pop
      answers
    end

    def gather_hash
      answers = {}

      question.gather.keys.sort.each do |key|
        @highline.key = key
        answers[key]  = ask_once
      end
      answers
    end

    ## Delegate to Highline

    private

    def explain_error(error)
      @highline.say(question.responses[error]) if error
      @highline.say(question.ask_on_error_msg)
    end
  end
end
