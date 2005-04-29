#!/usr/local/bin/ruby -w

# ts_all.rb
#
#  Created by James Edward Gray II on 2005-04-26.
#  Copyright 2005 Gray Productions. All rights reserved.

$test_dir ||= File.dirname(__FILE__)
$:.unshift($test_dir) unless $:.include?($test_dir)

require "test/unit"

require "tc_highline"
require "tc_import"
