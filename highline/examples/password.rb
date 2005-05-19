#!/usr/local/bin/ruby -w

$:.unshift(File.join(File.dirname(__FILE__), "..", "lib"))
require "highline/import"

pass = ask("Enter your password:  ") { |q| q.echo = false }
puts "Your password is #{pass}!"

