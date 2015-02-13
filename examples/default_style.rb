#!/usr/bin/env ruby

# default_style.rb
#
#  Created by Donald Guy on 2015-02-12

require 'rubygems'
require 'highline/import'

ask("Brackets right?") do |q|
    q.default = "yes"
    q.default_style = %w/[ ]/
end

ask("old school? ") do |q|
    q.default = "yes"
    q.default_style = "|"
end

ask("erb? ") do |q|
    q.default = "possible"
    q.default_style = ["[<%= color('", "', RED, BOLD) %>]"]
end

ask("placeholder? ") do |q|
    q.default = "so fancy"
    q.default_style = :placeholder
end

