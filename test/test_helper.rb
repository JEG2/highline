#!/usr/bin/env ruby
# coding: utf-8

require "English"

# Run code coverage only for mri
require "simplecov" if RUBY_ENGINE == "ruby"

# Compatibility module for StringIO, File
# and Tempfile. Necessary for some tests.
require "highline/io_console_compatible"

require "highline"

debug_message = <<~DEBUG_MESSAGE
  Tests will be run under:
    - #{HighLine.new.terminal.class}
    - HighLine::VERSION #{HighLine::VERSION}
DEBUG_MESSAGE

debug_message += "  - #{RUBY_DESCRIPTION}\n" if defined? RUBY_DESCRIPTION
puts debug_message

require "minitest/autorun"
