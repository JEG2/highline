#!/usr/local/bin/ruby -w

# ansi_colors.rb
#
#  Created by James Edward Gray II on 2005-05-03.
#  Copyright 2005 Gray Productions. All rights reserved.

require "rubygems"
require "highline/import"

# Supported color sequences.
colors = %w{black red green yellow blue magenta cyan white}

# Using color() with symbols.
colors.each_with_index do |c, i|
	say("This should be <%= color('#{c}', :#{c}) %>!")
	if i == 0
		say( "This should be " +
		     "<%= color('white on #{c}', :white, :on_#{c}) %>!")
	else
		say( "This should be " +
		     "<%= color( '#{colors[i - 1]} on #{c}',
		                 :#{colors[i - 1]}, :on_#{c} ) %>!")
	end
end

# Using color with constants.
say("This should be <%= color('bold', BOLD) %>!")
say("This should be <%= color('underlined', UNDERLINE) %>!")

# Using constants only.
say("This might even <%= BLINK %>blink<%= CLEAR %>!")
