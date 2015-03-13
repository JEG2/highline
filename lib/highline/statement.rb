class HighLine::Statement
  attr_reader :template_string, :highline

  def initialize(template_string, highline)
    @highline  = highline
    @template_string = stringfy(template_string)
  end

  def statement
    @statement ||= format_statement
  end

  def to_s
    statement
  end

  private

  def stringfy(template_string)
    String(template_string || "").dup
  end

  def format_statement
    return template_string unless template_string.length > 0

    statement = render_template

    statement = wrap(statement) unless highline.wrap_at.nil?
    statement = page_print(statement) unless highline.page_at.nil?

    # 'statement' is encoded in US-ASCII when using ruby 1.9.3(-p551)
    # 'indentation' is correctly encoded (same as default_external encoding)
    statement = statement.force_encoding(Encoding.default_external)

    statement = statement.gsub(/\n(?!$)/,"\n#{highline.indentation}") if highline.multi_indent
    statement
  end

  def render_template
    # Assigning to a local var so it may be
    # used inside instance eval block

    template_var = template
    highline.instance_eval { template_var.result(binding) }
  end

  def template
    @template ||= ERB.new(template_string, nil, "%")
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
    while lines.size > highline.page_at
      highline_output.puts lines.slice!(0...highline.page_at).join
      highline_output.puts
      # Return last line if user wants to abort paging
      return (["...\n"] + lines.slice(-2,1)).join unless highline.send(:continue_paging?)
    end
    return lines.join
  end

  def highline_output
    highline.instance_variable_get(:@output)
  end

  def self.const_missing(constant)
    HighLine.const_get(constant)
  end
end