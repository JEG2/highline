require 'highline/wrapper'
require 'highline/paginator'

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

    statement = Wrapper.wrap(statement, highline.wrap_at)
    statement = Paginator.new(highline).page_print(statement) unless highline.page_at.nil?

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

  def self.const_missing(constant)
    HighLine.const_get(constant)
  end
end