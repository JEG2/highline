# coding: utf-8

require_relative 'acceptance_test'

HighLine::AcceptanceTest.check do |t|
  t.desc =
    "This step checks if the readline autocomplete " \
    "feature is working. \n" \
    "The test has 5 options you can choose from: " \
    "save, sample, exec, exit and load.\n" \
    "If you type the first character of one of them and then press \n" \
    "the <TAB> key you should see the options available for autocomplete.\n\n" \
    "For example, if I type 's' and then I press <TAB> I should see a list\n" \
    "with 'save' and 'sample' as possible options for autocomplete.\n\n" \
    "Although, if I type 'l' and then press the <TAB> key it should be \n" \
    "readly autcompleted as 'load', because 'load' is the only option\n" \
    "that begins with the 'l' letter in this particular case.\n\n" \
    "If I don't type any character but press <TAB> two times, I should\n" \
    "be able to see ALL available options.\n\n" \
    "Please, play with Readline autocomplete for a while, pressing <ENTER>\n" \
    "to see that it really gets the selected answer.\n" \
    "When ready, just type 'exit' and the loop will finish.\n\n" \
    "Don't forget to answer 'y' (yes) or 'n' (no) to the question at the end."

  t.action = proc do
    loop do
      cmd =
        ask "Enter command:  ", %w[save sample exec exit load] do |q|
          q.readline = true
        end
      say("Executing \"#{cmd}\"...")
      break if cmd == "exit"
    end
  end

  t.question = "Did the Readline autocomplete work fine (y/n)? "
end
