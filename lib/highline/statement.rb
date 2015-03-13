class HighLine::Statement
  def format_statement statement
    statement = String(statement || "").dup
    return statement unless statement.length > 0

    template  = ERB.new(statement, nil, "%")
    statement = template.result(binding)

    statement = wrap(statement) unless @wrap_at.nil?
    statement = page_print(statement) unless @page_at.nil?

    # 'statement' is encoded in US-ASCII when using ruby 1.9.3(-p551)
    # 'indentation' is correctly encoded (same as default_external encoding)
    statement = statement.force_encoding(Encoding.default_external)

    statement = statement.gsub(/\n(?!$)/,"\n#{indentation}") if @multi_indent

    statement
  end

  #
  # Wrap a sequence of _lines_ at _wrap_at_ characters per line.  Existing
  # newlines will not be affected by this process, but additional newlines
  # may be added.
  #
  def wrap( text )
    wrapped = [ ]
    text.each_line do |line|
      # take into account color escape sequences when wrapping
      wrap_at = @wrap_at + (line.length - actual_length(line))
      while line =~ /([^\n]{#{wrap_at + 1},})/
        search  = $1.dup
        replace = $1.dup
        if index = replace.rindex(" ", wrap_at)
          replace[index, 1] = "\n"
          replace.sub!(/\n[ \t]+/, "\n")
          line.sub!(search, replace)
        else
          line[$~.begin(1) + wrap_at, 0] = "\n"
        end
      end
      wrapped << line
    end
    return wrapped.join
  end

  #
  # Page print a series of at most _page_at_ lines for _output_.  After each
  # page is printed, HighLine will pause until the user presses enter/return
  # then display the next page of data.
  #
  # Note that the final page of _output_ is *not* printed, but returned
  # instead.  This is to support any special handling for the final sequence.
  #
  def page_print( output )
    lines = output.scan(/[^\n]*\n?/)
    while lines.size > @page_at
      @output.puts lines.slice!(0...@page_at).join
      @output.puts
      # Return last line if user wants to abort paging
      return (["...\n"] + lines.slice(-2,1)).join unless continue_paging?
    end
    return lines.join
  end
end