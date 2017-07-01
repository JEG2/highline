# coding: utf-8

require_relative 'acceptance_test'

HighLine::AcceptanceTest.check do |t|
  t.desc =
    "This step checks if the 'echo = false' " \
    "setting is effective in hiding the user " \
    "typed characters.\n" \
    "This functionality is useful when asking " \
    "for passwords.\n" \
    "When typing the characters you should not " \
    "see any of them on the screen."

  t.action = proc do
    answer = ask "Enter some characters and press <enter>: " do |q|
      q.echo = false
    end
    puts "You've entered -> #{answer} <-"
  end

  t.question = "Were the characters adequately hidden when you typed them (y/n)? "
end
