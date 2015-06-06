#!/usr/bin/env ruby

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
        else
          send(answer_type.class.name)
        end

        check_range

        answer
      end

      private

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

      def Array
        self.answer = choices_complete(answer)
        answer.last
      end

      def Proc
        answer_type.call(answer)
      end
    end
  end
end