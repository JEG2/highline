#!/usr/local/bin/ruby -w

# basic_usage.rb
#
#  Created by James Edward Gray II on 2005-04-28.
#  Copyright 2005 Gray Productions. All rights reserved.

require "rubygems"
require "highline/import"
require "yaml"

contacts = [ ]

begin
	entry = Hash.new
	
	# basic output
	say("Enter a contact:")

	# basic input
	entry[:name]        = ask("Name?  (last, first)  ") do |q|
		q.validate = /\A\w+, ?\w+\Z/
	end
	entry[:company]     = ask("Company?  ") { |q| q.default = "none" }
	entry[:address]     = ask("Address?  ")
	entry[:city]        = ask("City?  ")
	entry[:state]       = ask("State?  ") { |q| q.validate = /\A[A-Z]{2}\Z/ }
	entry[:zip]         = ask("Zip?  ") do |q|
		q.validate = /\A\d{5}(?:-?\d{4})?\Z/
	end
	entry[:phone]       = ask( "Phone?  ",
	                           lambda { |p| p.delete("^0-9").
	                                          sub(/\A(\d{3})/, '(\1) ').
	                                          sub(/(\d{4})\Z/, '-\1') } ) do |q|
		q.validate              = lambda { |p| p.delete("^0-9").length == 10 }
		q.responses[:not_valid] = "Enter a phone numer with area code."
	end
	entry[:age]         = ask("Age?  ", Integer) { |q| q.in = 0..105 }
	entry[:birthday]    = ask("Birthday?  ", Date)
	entry[:interests]   = ask( "Interests?  (comma separated list)  ",
	                           lambda { |str| str.split(/,\s*/) } )
	entry[:description] = ask("Enter a description for this contact.")

	contacts << entry
# shortcut for yes and no questions
end while agree("Enter another contact?  ")

if agree("Save these contacts?  ")
	file_name = ask("Enter a file name:  ") { |q| q.validate = /\A\w+\Z/ }
	File.open("#{file_name}.yaml", "w") { |file| YAML.dump(contacts, file) }
end
