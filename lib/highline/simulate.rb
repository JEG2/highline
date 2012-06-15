# simulate.rb
#
#  Created by Andy Rossmeissl on 2012-04-29.
#  Copyright 2005 Gray Productions. All rights reserved.
#
#  This is Free Software.  See LICENSE and COPYING for details.
#
# adapted from https://gist.github.com/194554
class HighLine

  # Simulates Highline input for use in tests.
  class Simulate

    # Creates a simulator with an array of Strings as a script
    def initialize(strings)
      @strings = strings
    end
    
    # Simulate StringIO#gets by shifting a string off of the script
    def gets
      @strings.shift
    end

    # Simulate StringIO#getbyte by shifting a single character off of the next line of the script
    def getbyte
      line = gets
      if line.length > 0
        char = line.slice! 0
        @strings.unshift line
        char
      end
    end

    # The simulator handles its own EOF
    def eof?
      false
    end

    # A wrapper method that temporarily replaces the Highline instance in $terminal with an instance of this object for the duration of the block
    def self.with(*strings)
      @input = $terminal.instance_variable_get :@input
      $terminal.instance_variable_set :@input, new(strings)
      yield
    ensure
      $terminal.instance_variable_set :@input, @input
    end
  end
end
