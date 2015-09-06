#!/usr/bin/env ruby
# coding: utf-8

require 'simplecov'

if ENV['CODECLIMATE_REPO_TOKEN']
  require "codeclimate-test-reporter"
  CodeClimate::TestReporter.start
end

require 'highline'
debug_message = "Tests will be run under:\n"
debug_message << "  - #{HighLine.new.terminal.class}\n"
debug_message << "  - HighLine::VERSION #{HighLine::VERSION}\n"

if defined? RUBY_DESCRIPTION
  debug_message << "  - #{RUBY_DESCRIPTION}\n"
end

puts debug_message

require "minitest/autorun"
