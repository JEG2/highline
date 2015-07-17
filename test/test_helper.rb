#!/usr/bin/env ruby
# coding: utf-8

require 'simplecov'

if ENV['CODECLIMATE_REPO_TOKEN']
  require "codeclimate-test-reporter"
  CodeClimate::TestReporter.start
end

require 'highline'
puts "Tests will be run under #{HighLine.new.terminal.class}"

require "minitest/autorun"
