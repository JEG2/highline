#!/usr/local/bin/ruby -w

# import.rb
#
#  Created by James Edward Gray II on 2005-04-26.
#  Copyright 2005 Gray Productions. All rights reserved.

require "highline"
require "forwardable"

$terminal = HighLine.new

#
# <tt>require "highline/import"</tt> adds shorcut methods to Kernel, making
# agree(), ask(), choose() and say() globally available.  This is handy for
# quick and dirty input and output.  These methods use the HighLine object in
# the global variable <tt>$terminal</tt>, which is initialized to used
# <tt>$stdin</tt> and <tt>$stdout</tt> (you are free to change this).
# Otherwise, these methods areidentical to their HighLine counterparts, see that
# class for detailed explinations.
#
module Kernel
	extend Forwardable
	def_delegators :$terminal, :agree, :ask, :choose, :say
end
