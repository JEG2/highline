require "test_helper"

require "highline/import"
require "highline/simulate"

class SimulatorTest < Minitest::Test
  def setup
    input     = StringIO.new
    output    = StringIO.new
    HighLine.default_instance = HighLine.new(input, output)
  end

  def test_simulator
    HighLine::Simulate.with("Bugs Bunny", "18") do
      name = ask("What is your name?")

      assert_equal "Bugs Bunny", name

      age = ask("What is your age?")

      assert_equal "18", age
    end
  end
end
