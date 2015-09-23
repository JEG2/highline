require_relative 'statement'

class QuestionAsker
  attr_reader :question

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

  def initialize(question, highline)
    @question = question
    @highline = highline
  end

  def ask_once
    # readline() needs to handle its own output, but readline only supports
    # full line reading.  Therefore if question.echo is anything but true,
    # the prompt will not be issued. And we have to account for that now.
    # Also, JRuby-1.7's ConsoleReader.readLine() needs to be passed the prompt
    # to handle line editing properly.
    @highline.say(question) unless ((question.readline) and (question.echo == true and !question.limit))

    begin
      question.get_response_or_default(@highline)
      raise NotValidQuestionError unless question.valid_answer?

      question.convert

      if question.confirm
        # need to add a layer of scope (new_scope) to ask a question inside a
        # question, without destroying instance data

        raise NoConfirmationQuestionError unless @highline.send(:confirm, question)
      end

    rescue NoConfirmationQuestionError
      explain_error(nil)
      retry

    rescue HighLine::NotInRangeQuestionError
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

    rescue HighLine::Question::NoAutoCompleteMatch
      explain_error(:no_completion)
      retry
    end
    question.answer
  end

  ## Delegate to Highline

  private

  def explain_error(error)
    @highline.say(question.responses[error]) if error
    @highline.say(question.ask_on_error_msg)
  end
end
