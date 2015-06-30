# coding: utf-8

require 'forwardable'

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

        self.answer = convert_by_answer_type
        check_range
        answer
      end

      def to_string
        HighLine::String(answer)
      end

      # That's a weird name for a method!
      # But it's working ;-)
      define_method "to_highline::string" do
        HighLine::String(answer)
      end

      def to_integer
        Kernel.send(:Integer, answer)
      end

      def to_float
        Kernel.send(:Float, answer)
      end

      def to_symbol
        answer.to_sym
      end

      def to_regexp
        Regexp.new(answer)
      end

      def to_file
        self.answer = choices_complete(answer)
        File.open(File.join(directory.to_s, answer.last))
      end

      def to_pathname
        self.answer = choices_complete(answer)
        Pathname.new(File.join(directory.to_s, answer.last))
      end

      def to_array
        self.answer = choices_complete(answer)
        answer.last
      end

      def to_proc
        answer_type.call(answer)
      end

      private

      def convert_by_answer_type
        if answer_type.respond_to? :parse
          answer_type.parse(answer)
        elsif answer_type.is_a? Class
          send("to_#{answer_type.name.downcase}")
        else
          send("to_#{answer_type.class.name.downcase}")
        end
      end
    end
  end
end