#!/usr/local/bin/ruby -w

# color_scheme.rb
#
# Created by Richard LeBer on 2011-06-27.
# Copyright 2011.  All rights reserved
#
# This is Free Software.  See LICENSE and COPYING for details

require 'rubygems'
require 'hashie/mash'
require 'pp'

class HighLine
  
  def self.Style(*args)
    args = args.flatten
    if args.size==1
      arg = args.first
      if arg.is_a?(Style)
        name = arg.name
        Style.list[name] || Style.new(arg)
      elsif arg.is_a?(::String) && arg =~ /^\e\[/ # arg is a code
        if style = Style.code_index[arg]
          style
        else
          Style.new(:name=>'_code_'+arg[2..-1].gsub(/\W+/,'_'), :code=>arg)
        end
      elsif style = Style.list[arg.to_s.downcase]
        style
      elsif HighLine.color_scheme && HighLine.color_scheme[arg]
        Style(HighLine.color_scheme[arg])
      elsif arg.is_a?(Hash)
        Style.new(arg)
      elsif arg.to_s.downcase =~ /^rgb_(\d{6})$/
        Style.rgb($1)
      elsif arg.to_s.downcase =~ /^on_rgb_(\d{6})$/
        Style.rgb($1).on
      else
        raise NameError, "Don't know how to convert #{arg.inspect} to a Style"
      end
    else
      name = args
      Style.list[name] || Style.new(:list=>args)
    end
  end
  
  class Style < Hashie::Mash
    
    def self.define(style)
      name = style.name.to_s.downcase
      @@styles ||= {}
      @@styles[name] ||=  Style.new(nil, nil, :no_define=>true)
      @@styles[name].merge! style
      if !style.list?
        @@code_index ||= {}
        @@code_index[style.code] ||= Style.new(nil, nil, :no_define=>true)
        @@code_index[style.code].merge! style
      end
      style
    end
    
    def self.rgb_hex(*colors)
      colors.map do |color|
        color.is_a?(Numeric) ? '%02x'%color : color.to_s
      end.join
    end
    
    def self.rgb_parts(hex)
      hex.scan(/../).map{|part| part.to_i(16)}
    end
    
    def self.rgb(*colors)
      hex = rgb_hex(*colors)
      name = 'rgb_' + hex
      if style = list[name]
        style
      else
        parts = rgb_parts(hex)
        rgb_number = 16 + parts.inject(0) {|kode, part| kode*6 + (part/256.0*6.0).floor}
        new(:name=>name, :code=>"\e[38;5;#{rgb_number}m", :rgb=>parts)
      end
    end
    
    def self.list
      @@styles ||= {}
    end
    
    def self.code_index
      @@code_index ||= {}
    end
    
    def self.uncolor(string)
      string.gsub(/\e\[\d+(;\d+)*m/, '')
    end
    
    # Normal attributes: 
    #   For a color: name, code, rgb
    #   For a style (like :blink): name, code
    #   For a compound style (like :underline, :red): list
    
    def initialize(hsh = nil, default = nil, options={}, &blk)
      super(hsh, default, &blk)
      if rgb
        hex = self.class.rgb_hex(rgb)
        rgb = self.class.rgb_parts(hex)
        name ||= 'rgb_' + hex
      else
        name ||= list
      end
      self.class.define self unless options[:no_define]
    end
    
    def color(string)
      code + string + HighLine::CLEAR
    end
    
    def code
      if list
        list.map{|element| HighLine.Style(element).code}.join
      else
        self['code']
      end
    end
      
    def red
      rgb && rgb[0]
    end

    def green
      rgb && rgb[1]
    end

    def blue
      rgb && rgb[2]
    end
    
    def bumped(name, increment)
      new_style = self.dup
      new_style.name = name
      raise "Unexpected code in #{self.inspect}" unless code =~ /^(.*?)(\d+)(.*)/
      new_style.code = $1 + ($2.to_i + increment).to_s + $3
      self.class.define new_style
    end
    
    def on
      new_name = 'on_'+name
      self.class.list[new_name] ||= bumped(new_name, 10)
    end
    
    def bright
      new_name = 'bright_'+name
      if style = self.class.list[new_name]
        style
      else
        new_style = bumped(new_name, 60)
        if self.rgb == [0,0,0]
          new_style.rgb = [128, 128, 128]
        else
          new_style.rgb = self.rgb.map {|color|  color==0 ? 0 : 255 }
        end
        new_style
      end
    end
  end
end
