unless STDIN.respond_to?(:getbyte)
  class IO
    alias_method :getbyte, :getc
  end

  class StringIO
    alias_method :getbyte, :getc
  end
end

unless "".respond_to?(:lines)
  
  # Not a perfect translation, but sufficient for our needs.
  class String
    alias_method :lines, :to_a
  end
end
