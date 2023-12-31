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
    #
    # Rubinius (and JRuby) seems to be ignoring
    # Readline input and output assignments. This
    # ruins testing.
    #
    # But it doesn't mean readline is not working
    # properly on rubinius or jruby.
    #

    terminal = @terminal.terminal

    if terminal.jruby? || terminal.rubinius? || terminal.windows?
      skip "We can't test Readline on JRuby, Rubinius and Windows yet"
    end

    # Creating Tempfiles here because Readline.input
    #   and Readline.output only accepts a File object
    #   as argument (not any duck type as StringIO)

    temp_stdin  = Tempfile.new "temp_stdin"
    temp_stdout = Tempfile.new "temp_stdout"

    Readline.input  = @input  = File.open(temp_stdin.path, "w+")
    Readline.output = @output = File.open(temp_stdout.path, "w+")

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
    Readline.input  = STDIN
    Readline.output = STDOUT
  end

  def test_readline_mode_with_limit_set
    temp_stdin  = Tempfile.new "temp_stdin"
    temp_stdout = Tempfile.new "temp_stdout"

    Readline.input  = @input  = File.open(temp_stdin.path, "w+")
    Readline.output = @output = File.open(temp_stdout.path, "w+")

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
    assert_equal "Prompt:  any input\n", output

    @input.close
    @output.close
    Readline.input  = STDIN
    Readline.output = STDOUT
  end

  def test_readline_on_non_echo_question_has_prompt
    @input << "you can't see me"
    @input.rewind
    answer = @terminal.ask("Please enter some hidden text: ") do |q|
      q.readline = true
      q.echo = "*"
    end
    assert_equal("you can't see me", answer)
    assert_equal("Please enter some hidden text: ****************\n",
                 @output.string)
  end
end
