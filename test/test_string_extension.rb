#!/usr/bin/env ruby
# coding: utf-8

# tc_string_extension.rb
#
#  Created by Richard LeBer 2011-06-27
#
#  This is Free Software.  See LICENSE and COPYING for details.

require "test_helper"

require "highline"
require "stringio"
require "string_methods"

# FakeString is here just to avoid
# using HighLine.colorize_strings
# on tests

class FakeString < String
  include HighLine::StringExtensions
end

class TestStringExtension < Minitest::Test
  def setup
    HighLine.reset
    @string = FakeString.new "string"
  end

  def teardown
    HighLine.reset
  end

  include StringMethods

  def test_Highline_String_is_yaml_serializable
    require 'yaml'
    unless Gem::Version.new(YAML::VERSION) < Gem::Version.new("2.0.2")
      highline_string = HighLine::String.new("Yaml didn't messed with HighLine::String")
      yaml_highline_string = highline_string.to_yaml
      yaml_loaded_string = YAML.safe_load(yaml_highline_string, [HighLine::String])

      assert_equal "Yaml didn't messed with HighLine::String", yaml_loaded_string
      assert_equal highline_string, yaml_loaded_string
      assert_instance_of HighLine::String, yaml_loaded_string
    end
  end

  def test_highline_string_respond_to_color
    assert HighLine::String.new("highline string").respond_to? :color
  end

  def test_normal_string_doesnt_respond_to_color
    refute "normal_string".respond_to? :color
  end

  def test_highline_string_still_raises_for_non_available_messages
    assert_raises(NoMethodError) do
      @string.unknown_message
    end
  end

  def test_String_includes_StringExtension_when_receives_colorize_strings
    @include_received = 0
    caller = proc { @include_received += 1 }
    ::String.stub :include, caller do
      HighLine.colorize_strings
    end
    assert_equal 1, @include_received
  end
end
