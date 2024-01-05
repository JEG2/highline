require "test_helper"
require "reline"

class TestReline < Minitest::Test
  def setup
    HighLine.reset
    @input    = StringIO.new
    @output   = StringIO.new
    @terminal = HighLine.new(@input, @output)
  end

  def test_readline_mode
    # See #267
    skip "We need vterm / yamatanooroti based tests for reline"

    # Creating Tempfiles here because Readline.input
    #   and Readline.output only accepts a File object
    #   as argument (not any duck type as StringIO)

    temp_stdin  = Tempfile.new "temp_stdin"
    temp_stdout = Tempfile.new "temp_stdout"

    Reline.input  = @input  = File.open(temp_stdin.path, "w+")
    Reline.output = @output = File.open(temp_stdout.path, "w+")

    @terminal = HighLine.new(@input, @output)

    @input << "any input\n"
    @input.rewind

    answer = @terminal.ask("Prompt:  ") do |q|
      q.readline = true
    end

    @output.rewind
    output = @output.read

    assert_equal "any input", answer
    assert_match "Prompt:  any input\n", output

    @input.close
    @output.close
    Reline.input  = STDIN
    Reline.output = STDOUT
  end

  def test_readline_mode_with_limit_set
    temp_stdin  = Tempfile.new "temp_stdin"
    temp_stdout = Tempfile.new "temp_stdout"

    Reline.input  = @input  = File.open(temp_stdin.path, "w+")
    Reline.output = @output = File.open(temp_stdout.path, "w+")

    @terminal = HighLine.new(@input, @output)

    @input << "any input\n"
    @input.rewind

    answer = @terminal.ask("Prompt:  ") do |q|
      q.limit = 50
      q.readline = true
    end

    @output.rewind
    output = @output.read

    assert_equal "any input", answer

    # after migrating to Reline, we can't make assertions about the output
    # without using vterm / yamatanooroti. See #267
    #
    # assert_equal "Prompt:  any input\n", output

    @input.close
    @output.close
    Reline.input  = STDIN
    Reline.output = STDOUT
  end

  def test_readline_on_non_echo_question_has_prompt
    @input << "you can't see me"
    @input.rewind
    answer = @terminal.ask("Please enter some hidden text: ") do |q|
      q.readline = true
      q.echo = "*"
    end
    assert_equal("you can't see me", answer)

    # after migrating to Reline, we can't make assertions about the output
    # without using vterm / yamatanooroti. See #267
    #
    # assert_equal("Please enter some hidden text: ****************\n",
    #             @output.string)
  end
end
