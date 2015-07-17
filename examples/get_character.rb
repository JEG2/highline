#!/usr/bin/env ruby

require "rubygems"
require "highline/import"

puts "Using: #{$terminal.terminal.class}"
puts

choices = "ynaq"
answer = ask("Your choice [#{choices}]? ") do |q|
           q.echo      = false
           q.character = true
           q.validate  = /\A[#{choices}]\Z/
         end
say("Your choice: #{answer}")
