# coding: utf-8

class HighLine
  def self.String(s)
    HighLine::String.new(s)
  end

  # HighLine extensions for String class
  # Included by HighLine::String
  module StringExtensions
    def self.included(base)
      HighLine::COLORS.each do |color|
        color = color.downcase
        base.class_eval <<-END
          undef :#{color} if method_defined? :#{color}
          def #{color}
            color(:#{color})
          end
        END

        base.class_eval <<-END
          undef :on_#{color} if method_defined? :on_#{color}
          def on_#{color}
            on(:#{color})
          end
        END
        HighLine::STYLES.each do |style|
          style = style.downcase
          base.class_eval <<-END
            undef :#{style} if method_defined? :#{style}
            def #{style}
              color(:#{style})
            end
          END
        end
      end

      base.class_eval do
        undef :color if method_defined? :color
        undef :foreground if method_defined? :foreground
        def color(*args)
          self.class.new(HighLine.color(self, *args))
        end
        alias_method :foreground, :color

        undef :on if method_defined? :on
        def on(arg)
          color(('on_' + arg.to_s).to_sym)
        end

        undef :uncolor if method_defined? :uncolor
        def uncolor
          self.class.new(HighLine.uncolor(self))
        end

        undef :rgb if method_defined? :rgb
        def rgb(*colors)
          color_code = colors.map{|color| color.is_a?(Numeric) ? '%02x'%color : color.to_s}.join
          raise "Bad RGB color #{colors.inspect}" unless color_code =~ /^[a-fA-F0-9]{6}/
          color("rgb_#{color_code}".to_sym)
        end

        undef :on_rgb if method_defined? :on_rgb
        def on_rgb(*colors)
          color_code = colors.map{|color| color.is_a?(Numeric) ? '%02x'%color : color.to_s}.join
          raise "Bad RGB color #{colors.inspect}" unless color_code =~ /^[a-fA-F0-9]{6}/
          color("on_rgb_#{color_code}".to_sym)
        end

        # TODO Chain existing method_missing
        undef :method_missing if method_defined? :method_missing
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

  def self.colorize_strings
    ::String.send(:include, StringExtensions)
  end
end
