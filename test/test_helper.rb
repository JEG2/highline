#!/usr/bin/env ruby
# coding: utf-8

require 'simplecov'
SimpleCov.start do
  add_filter "test_"
end

require "codeclimate-test-reporter"
CodeClimate::TestReporter.start

require "minitest/autorun"
