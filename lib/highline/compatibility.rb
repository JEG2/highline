unless STDIN.respond_to?(:getbyte)
  class IO
    alias_method :getbyte, :getc
  end

  class StringIO
    alias_method :getbyte, :getc
  end
end

unless "".respond_to?(:each_line)
  
  # Not a perfect translation, but sufficient for our needs.
  class String
    def each_line
      to_a.each { |line| yield(line) }
    end
  end
end
