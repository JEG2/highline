#coding: utf-8

class HighLine
  module BuiltinStyles
    #
    # Embed in a String to clear all previous ANSI sequences.  This *MUST* be
    # done before the program exits!
    #

    ERASE_LINE_STYLE = Style.new(:name=>:erase_line, :builtin=>true, :code=>"\e[K")  # Erase the current line of terminal output
    ERASE_CHAR_STYLE = Style.new(:name=>:erase_char, :builtin=>true, :code=>"\e[P")  # Erase the character under the cursor.
    CLEAR_STYLE      = Style.new(:name=>:clear,      :builtin=>true, :code=>"\e[0m") # Clear color settings
    RESET_STYLE      = Style.new(:name=>:reset,      :builtin=>true, :code=>"\e[0m") # Alias for CLEAR.
    BOLD_STYLE       = Style.new(:name=>:bold,       :builtin=>true, :code=>"\e[1m") # Bold; Note: bold + a color works as you'd expect,
                                                                # for example bold black. Bold without a color displays
                                                                # the system-defined bold color (e.g. red on Mac iTerm)
    DARK_STYLE       = Style.new(:name=>:dark,       :builtin=>true, :code=>"\e[2m") # Dark; support uncommon
    UNDERLINE_STYLE  = Style.new(:name=>:underline,  :builtin=>true, :code=>"\e[4m") # Underline
    UNDERSCORE_STYLE = Style.new(:name=>:underscore, :builtin=>true, :code=>"\e[4m") # Alias for UNDERLINE
    BLINK_STYLE      = Style.new(:name=>:blink,      :builtin=>true, :code=>"\e[5m") # Blink; support uncommon
    REVERSE_STYLE    = Style.new(:name=>:reverse,    :builtin=>true, :code=>"\e[7m") # Reverse foreground and background
    CONCEALED_STYLE  = Style.new(:name=>:concealed,  :builtin=>true, :code=>"\e[8m") # Concealed; support uncommon

    STYLES = %w{CLEAR RESET BOLD DARK UNDERLINE UNDERSCORE BLINK REVERSE CONCEALED}

    # These RGB colors are approximate; see http://en.wikipedia.org/wiki/ANSI_escape_code
    BLACK_STYLE      = Style.new(:name=>:black,      :builtin=>true, :code=>"\e[30m", :rgb=>[  0,  0,  0])
    RED_STYLE        = Style.new(:name=>:red,        :builtin=>true, :code=>"\e[31m", :rgb=>[128,  0,  0])
    GREEN_STYLE      = Style.new(:name=>:green,      :builtin=>true, :code=>"\e[32m", :rgb=>[  0,128,  0])
    BLUE_STYLE       = Style.new(:name=>:blue,       :builtin=>true, :code=>"\e[34m", :rgb=>[  0,  0,128])
    YELLOW_STYLE     = Style.new(:name=>:yellow,     :builtin=>true, :code=>"\e[33m", :rgb=>[128,128,  0])
    MAGENTA_STYLE    = Style.new(:name=>:magenta,    :builtin=>true, :code=>"\e[35m", :rgb=>[128,  0,128])
    CYAN_STYLE       = Style.new(:name=>:cyan,       :builtin=>true, :code=>"\e[36m", :rgb=>[  0,128,128])
    # On Mac OSX Terminal, white is actually gray
    WHITE_STYLE      = Style.new(:name=>:white,      :builtin=>true, :code=>"\e[37m", :rgb=>[192,192,192])
    # Alias for WHITE, since WHITE is actually a light gray on Macs
    GRAY_STYLE       = Style.new(:name=>:gray,       :builtin=>true, :code=>"\e[37m", :rgb=>[192,192,192])
    GREY_STYLE       = Style.new(:name=>:grey,       :builtin=>true, :code=>"\e[37m", :rgb=>[192,192,192])
    # On Mac OSX Terminal, this is black foreground, or bright white background.
    # Also used as base for RGB colors, if available
    NONE_STYLE       = Style.new(:name=>:none,       :builtin=>true, :code=>"\e[38m", :rgb=>[  0,  0,  0])

    BASIC_COLORS = %w{BLACK RED GREEN YELLOW BLUE MAGENTA CYAN WHITE GRAY GREY NONE}

    colors = BASIC_COLORS.dup
    BASIC_COLORS.each do |color|
      bright_color = "BRIGHT_#{color}"
      colors << bright_color
      const_set bright_color+'_STYLE', const_get(color + '_STYLE').bright

      light_color = "LIGHT_#{color}"
      colors << light_color
      const_set light_color+'_STYLE', const_get(color + '_STYLE').light
    end
    COLORS = colors

    colors.each do |color|
      const_set color, const_get("#{color}_STYLE").code
      const_set "ON_#{color}_STYLE", const_get("#{color}_STYLE").on
      const_set "ON_#{color}", const_get("ON_#{color}_STYLE").code
    end
    ON_NONE_STYLE.rgb = [255,255,255] # Override; white background

    STYLES.each do |style|
      const_set style, const_get("#{style}_STYLE").code
    end

    # For RGB colors:
    def self.const_missing(name)
      if name.to_s =~ /^(ON_)?(RGB_)([A-F0-9]{6})(_STYLE)?$/ # RGB color
        on = $1
        suffix = $4
        if suffix
          code_name = $1.to_s + $2 + $3
        else
          code_name = name.to_s
        end
        style_name = code_name + '_STYLE'
        style = Style.rgb($3)
        style = style.on if on
        const_set(style_name, style)
        const_set(code_name, style.code)
        if suffix
          style
        else
          style.code
        end
      else
        raise NameError, "Bad color or uninitialized constant #{name}"
      end
    end
  end
end