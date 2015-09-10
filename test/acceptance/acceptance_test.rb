# coding: utf-8

require 'highline/import'

class HighLine::AcceptanceTest
  @@answers ||= {}

  def self.check(&block)
    caller_file = File.basename(caller[0].split(":")[-3])

    test = new
    yield test
    test.caller_file = caller_file
    test.check
  end

  def self.answers
    @@answers
  end

  def self.answers_for_report
    answers.map do |file, answer|
      "#{file}: #{answer}"
    end.join("\n")
  end

  # A test description to be shown to user.
  # It should express what the user is
  # expected to check.
  attr_accessor :desc

  # A test action to be checked by the user
  attr_accessor :action

  # A text asking the confirmation if
  # the action worked (y) or not (n).
  attr_accessor :question

  # Automatically filled attribute pointing
  # to the file where the current test
  # source is located. So we could check
  # at the report what tests passed or failed.
  attr_accessor :caller_file

  def check
    # Print a header with the test description
    puts "====="
    puts "   #{caller_file}"
    puts "====="
    puts
    puts desc

    # Execute the proc/lambda assigned to action
    puts "---"
    puts
    action.call
    puts
    puts "---"
    puts

    # Gather the user feedback about the test
    print question
    answer = STDIN.gets.chomp
    answer = "y" if answer.empty?
    @@answers[caller_file] = answer

    puts
  end
end
