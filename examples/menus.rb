#!/usr/local/bin/ruby -w

require "rubygems"
require "highline/import"

choices = %w{ruby python perl}

say("Please choose your favorite programming language:")
say(choices.map { |c| "  #{c}\n" }.join)

case ask("?  ", choices)
when "ruby"
	say("Good choice!")
else
	say("Not from around here, are you?")
end
