#!/usr/bin/env ruby
# coding: utf-8

require 'simplecov'

if ENV['CODECLIMATE_REPO_TOKEN']
  require "codeclimate-test-reporter"
  CodeClimate::TestReporter.start
end

require 'highline'
debug_message = "Tests will be run under #{HighLine.new.terminal.class} "

if defined? RUBY_DESCRIPTION
  debug_message << "#{RUBY_DESCRIPTION} "
end

puts debug_message

require "minitest/autorun"
