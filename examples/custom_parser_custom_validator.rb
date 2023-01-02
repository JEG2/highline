require 'highline'

cli = HighLine.new

# The parser
class ArrayOfNumbersFromString
  def self.parse(string)
    string.scan(/\d+/).map(&:to_i)
  end
end

# The validator
class ArrayOfNumbersFromStringInRange
  def self.in?(range)
    new(range)
  end

  attr_reader :range

  def initialize(range)
    @range = range
  end

  def valid?(answer)
    ary = ArrayOfNumbersFromString.parse(answer)
    ary.all? ->(number) { range.include? number }
  end

  def inspect
    "in range #@range validator"
  end
end

answer = cli.ask("Which number? (0 or <Enter> to skip): ", ArrayOfNumbersFromString) { |q|
  q.validate = ArrayOfNumbersFromStringInRange.in?(0..10)
  q.default = 0
}

puts "Your answer was: #{answer} and it was correctly validated and coerced into an #{answer.class}"
