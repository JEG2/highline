#!/usr/local/bin/ruby -w

require "rubygems"
require "highline/import"

#choices = %w{ruby python perl}

#say("Please choose your favorite programming language:")
#say(choices.map { |c| "  #{c}\n" }.join)

#case ask("?  ", choices)
#when "ruby"
#	say("Good choice!")
#else
#	say("Not from around here, are you?")
#end

choose do |menu|
	menu.header = "Please choose your favorite programming language"
	menu.choice :ruby do say("Good choice!") end
	menu.choices(:python, :perl) do say("Not from around here, are you?") end
end


