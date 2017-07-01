#!/usr/bin/env ruby
# coding: utf-8

require "English"

# Run code coverage only for mri
require 'simplecov' if RUBY_ENGINE == 'ruby'

# Compatibility module for StringIO, File
# and Tempfile. Necessary for some tests.
require "io_console_compatible"

require 'highline'
debug_message = "Tests will be run under:\n"
debug_message << "  - #{HighLine.new.terminal.class}\n"
debug_message << "  - HighLine::VERSION #{HighLine::VERSION}\n"

debug_message << "  - #{RUBY_DESCRIPTION}\n" if defined? RUBY_DESCRIPTION

puts debug_message

require "minitest/autorun"
