# coding: utf-8

require_relative "acceptance_test"

HighLine::AcceptanceTest.check do |t|
  t.desc =
    "This step checks if the readline works well with agree.\n" \
    "You should press <tab> and readline should give the default " \
    "(yes/no) options to autocomplete."

  t.action = proc do
    answer = agree("Do you agree?") { |q| q.readline = true }
    puts "You've entered -> #{answer} <-"
  end

  t.question =
    "Did HighLine#agree worked well using question.readline = true (y/n)? "
end
