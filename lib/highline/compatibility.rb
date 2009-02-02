unless STDIN.respond_to?(:getbyte)
  class IO
    alias_method :getbyte, :getc
  end

  class StringIO
    alias_method :getbyte, :getc
  end
end
