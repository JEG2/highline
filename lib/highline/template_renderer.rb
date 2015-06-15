# coding: utf-8

require 'forwardable'

class HighLine
  class TemplateRenderer
    extend Forwardable

    def_delegators :@highline, :color, :list, :key, :question
    def_delegators :@source, :answer_type, :prompt, :header, :answer

    attr_reader :template, :source, :highline

    def initialize(template, source, highline)
      @template = template
      @source   = source
      @highline = highline
    end

    def render
      template.result(binding)
    end

    def method_missing(method, *args)
      "Method #{method} with args #{args.inspect} " +
      "is not available on #{self.inspect}. " +
      "Try #{methods(false).sort.inspect}"
    end

    def menu
      source
    end

    def self.const_missing(name)
      HighLine.const_get(name)
    end
  end
end