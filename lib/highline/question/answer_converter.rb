#!/usr/bin/env ruby

# TODO: This module was extracted from HighLine::Question
# Now the dependencies are clear. See the delegators.
# Remember to refactor it!

class HighLine
  class Question
    class AnswerConverter
      extend Forwardable

      def_delegators :@question,
                     :answer, :answer=, :check_range,
                     :directory, :answer_type, :choices_complete

      def initialize(question)
        @question = question
      end

      def convert
        return unless answer_type

        self.answer =
        if [::String, HighLine::String].include?(answer_type)
          HighLine::String(answer)
        elsif [Float, Integer].include?(answer_type)
          Kernel.send(answer_type.to_s.to_sym, answer)
        elsif answer_type == Symbol
          answer.to_sym
        elsif answer_type == Regexp
          Regexp.new(answer)
        elsif answer_type.is_a?(Array) or [File, Pathname].include?(answer_type)
          self.answer = choices_complete(answer)
          if answer_type.is_a?(Array)
            answer.last
          elsif answer_type == File
            File.open(File.join(directory.to_s, answer.last))
          else
            Pathname.new(File.join(directory.to_s, answer.last))
          end
        elsif answer_type.respond_to? :parse
          answer_type.parse(answer)
        elsif answer_type.is_a?(Proc)
          answer_type.call(answer)
        end

        check_range

        answer
      end
    end
  end
end