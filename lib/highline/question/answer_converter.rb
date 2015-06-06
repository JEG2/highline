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
        if answer_type.respond_to? :parse
          answer_type.parse(answer)
        elsif answer_type.is_a? Class
          send(answer_type.name)
        elsif answer_type.is_a?(Array)
          self.answer = choices_complete(answer)
          answer.last
        elsif answer_type.is_a?(Proc)
          answer_type.call(answer)
        end

        check_range

        answer
      end

      def String
        HighLine::String(answer)
      end

      # That's a weird name for a method!
      # But it's working ;-)
      define_method "HighLine::String" do
        HighLine::String(answer)
      end

      def Integer
        Kernel.send(:Integer, answer)
      end

      def Float
        Kernel.send(:Float, answer)
      end

      def Symbol
        answer.to_sym
      end

      def Regexp
        Regexp.new(answer)
      end

      def File
        self.answer = choices_complete(answer)
        File.open(File.join(directory.to_s, answer.last))
      end

      def Pathname
        self.answer = choices_complete(answer)
        Pathname.new(File.join(directory.to_s, answer.last))
      end
    end
  end
end