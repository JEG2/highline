# coding: utf-8

require 'highline/wrapper'
require 'highline/paginator'
require 'highline/template_renderer'

class HighLine::Statement
  attr_reader :source, :highline
  attr_reader :template_string

  def initialize(source, highline)
    @highline = highline
    @source   = source
    @template_string = stringfy(source)
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

    statement = HighLine::Wrapper.wrap(statement, highline.wrap_at)
    statement = HighLine::Paginator.new(highline).page_print(statement)

    statement = statement.gsub(/\n(?!$)/,"\n#{highline.indentation}") if highline.multi_indent
    statement
  end

  def render_template
    # Assigning to a local var so it may be
    # used inside instance eval block

    template_renderer = TemplateRenderer.new(template, source, highline)
    template_renderer.render
  end

  def template
    @template ||= ERB.new(template_string, nil, "%")
  end

  def self.const_missing(constant)
    HighLine.const_get(constant)
  end
end