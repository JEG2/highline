# Extensions for class String
#
# HighLine::String is a subclass of String with convenience methods added for colorization.
#
# Available convenience methods include:
#   * 'color' method         e.g.  highline_string.color(:bright_blue, :underline)
#   * colors                 e.g.  highline_string.magenta
#   * RGB colors             e.g.  highline_string.rgb_ff6000
#                             or   highline_string.rgb(255,96,0)
#   * background colors      e.g.  highline_string.on_magenta
#   * RGB background colors  e.g.  highline_string.on_rgb_ff6000
#                             or   highline_string.on_rgb(255,96,0)
#   * styles                 e.g.  highline_string.underline
#
# Additionally, convenience methods can be chained, for instance the following are equivalent:
#   highline_string.bright_blue.blink.underline
#   highline_string.color(:bright_blue, :blink, :underline)
#   HighLine.color(highline_string, :bright_blue, :blink, :underline)
#
# For those less squeamish about possible conflicts, the same convenience methods can be 
# added to the builtin String class, as follows:
#
#  require 'highline'
#  Highline.colorize_strings

class HighLine
  def self.String(s)
    HighLine::String.new(s)
  end
  
  module StringExtensions
    def self.included(base)
      HighLine::COLORS.each do |color|
        base.class_eval <<-END
          def #{color.downcase}
            color(:#{color.downcase})
          end
        END
        base.class_eval <<-END
          def on_#{color.downcase}
            on(:#{color.downcase})
          end
        END
        HighLine::STYLES.each do |style|
          base.class_eval <<-END
            def #{style.downcase}
              color(:#{style.downcase})
            end
          END
        end
      end
      
      base.class_eval do
        def color(*args)
          self.class.new(HighLine.color(self, *args))
        end
        alias_method :foreground, :color
        
        def on(arg)
          color(('on_' + arg.to_s).to_sym)
        end

        def uncolor
          self.class.new(HighLine.uncolor(self))
        end
        
        def rgb(*colors)
          color_code = colors.map{|color| color.is_a?(Numeric) ? '%02x'%color : color.to_s}.join
          raise "Bad RGB color #{colors.inspect}" unless color_code =~ /^[a-fA-F0-9]{6}/
          color("rgb_#{color_code}".to_sym)
        end
        
        def on_rgb(*colors)
          color_code = colors.map{|color| color.is_a?(Numeric) ? '%02x'%color : color.to_s}.join
          raise "Bad RGB color #{colors.inspect}" unless color_code =~ /^[a-fA-F0-9]{6}/
          color("on_rgb_#{color_code}".to_sym)
        end
        
        # TODO Chain existing method_missing
        def method_missing(method, *args, &blk)
          if method.to_s =~ /^(on_)?rgb_([0-9a-fA-F]{6})$/
            color(method)
          else
            raise NoMethodError, "undefined method `#{method}' for #<#{self.class}:#{'%#x'%self.object_id}>"
          end
        end
      end
    end
  end
  
  class HighLine::String < ::String
    include StringExtensions
  end
  
  def self.colorize_strings
    ::String.send(:include, StringExtensions)
  end
end