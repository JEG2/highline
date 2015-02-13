#!/usr/bin/env ruby

# placeholder.rb
#
#  Created by Donald Guy on 2015-02-12

require 'rubygems'
require 'highline/import'

name = ask("What's your name?") do |q|
    q.default = "#{ENV['USER']}"
    q.default_style = :placeholder
    q.placeholder_color = :red
end
say("Your name is <%= color('#{name}', GREEN) %>")
