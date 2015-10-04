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

        answers = gather_answers_based_on_type

        if verify_match && (@highline.send(:unique_answers, answers).size > 1)
          explain_error(:mismatch)
        else
          verify_match = false
        end
      end while verify_match

      question.verify_match ? @highline.send(:last_answer, answers) : answers
    end

    def gather_integer
      gather_with_array do |answers|
        (question.gather-1).times { answers << ask_once }
      end
    end

    def gather_regexp
      gather_with_array do |answers|
        answers << ask_once until answer_matches_regex(answers.last)
        answers.pop
      end
    end

    def gather_hash
      answers = {}

      question.gather.keys.sort.each do |key|
        @highline.key = key
        answers[key]  = ask_once
      end
      answers
    end


    private

    ## Delegate to Highline
    def explain_error(error)
      @highline.say(question.responses[error]) if error
      @highline.say(question.ask_on_error_msg)
    end

    def gather_with_array
      [].tap do |answers|
        answers << ask_once
        question.template = ""

        yield answers
      end
    end

    def answer_matches_regex(answer)
      (question.gather.is_a?(::String) && answer.to_s == question.gather) ||
      (question.gather.is_a?(Regexp)   && answer.to_s =~ question.gather)
    end

    def gather_answers_based_on_type
      case question.gather
      when Integer
        gather_integer
      when ::String, Regexp
        gather_regexp
      when Hash
        gather_hash
      end
    end
  end
end
