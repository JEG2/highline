# coding: utf-8

unless STDIN.respond_to? :getbyte
  # HighLine adds #getbyte alias to #getc when #getbyte is not available.
  class IO
    alias_method :getbyte, :getc
  end

  # HighLine adds #getbyte alias to #getc when #getbyte is not available.
  class StringIO
    alias_method :getbyte, :getc
  end
end

unless "".respond_to? :each_line
  # HighLine adds #each_line alias to #each when each_line is not available.
  class String
    alias_method :each_line, :each
  end
end
