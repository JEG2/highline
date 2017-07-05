# coding: utf-8

require_relative "acceptance_test"

HighLine::AcceptanceTest.check do |t|
  t.desc =
    "This step checks if coloring "       \
    "with erb templates is working ok.\n" \
    "You should see the word _grass_ "    \
    "colored in green color"

  t.action = proc do
    say "The <%= color('grass', :green) %> should be green!"
  end

  t.question = "Do you see the word 'grass' on green color (y/n)? "
end
