#!/usr/bin/env ruby
# coding: utf-8

# tc_import.rb
#
#  Created by James Edward Gray II on 2005-04-26.
#  Copyright 2005 Gray Productions. All rights reserved.
#
#  This is Free Software.  See LICENSE and COPYING for details.

require "test_helper"

require "highline/import"
require "stringio"

class TestImport < Minitest::Test
  def test_import
    assert_respond_to(self, :agree)
    assert_respond_to(self, :ask)
    assert_respond_to(self, :choose)
    assert_respond_to(self, :say)
  end

  def test_healthy_default_instance_after_import
    refute_nil HighLine.default_instance
    assert_instance_of HighLine, HighLine.default_instance

    # If correctly initialized, it will contain several ins vars.
    refute_empty HighLine.default_instance.instance_variables
  end
  
  def test_or_ask
    old_instance = HighLine.default_instance
    
    input     = StringIO.new
    output    = StringIO.new
    HighLine.default_instance = HighLine.new(input, output)  
    
    input << "10\n"
    input.rewind

    assert_equal(10, nil.or_ask("How much?  ", Integer))

    input.rewind

    assert_equal(20, "20".or_ask("How much?  ", Integer))
    assert_equal(20, 20.or_ask("How much?  ", Integer))
    
    assert_equal(10, 20.or_ask("How much?  ", Integer) { |q| q.in = 1..10 })
  ensure
    HighLine.default_instance = old_instance
  end
  
  def test_redirection
    old_instance = HighLine.default_instance
    
    HighLine.default_instance = HighLine.new(nil, (output = StringIO.new))
    say("Testing...")
    assert_equal("Testing...\n", output.string)
  ensure
    HighLine.default_instance = old_instance
  end
end
