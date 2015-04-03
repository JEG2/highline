require 'highline/template_renderer'
require 'highline/wrapper'

class HighLine::List
  attr_reader :items, :mode, :option, :highline

  def initialize(items, mode = :rows, option = nil, highline)
    @highline = highline
    @mode     = mode
    @option   = option
    @items    = render_list_items(items)
  end

  #
  # This method is a utility for quickly and easily laying out lists.  It can
  # be accessed within ERb replacements of any text that will be sent to the
  # user.
  #
  # The only required parameter is _items_, which should be the Array of items
  # to list.  A specified _mode_ controls how that list is formed and _option_
  # has different effects, depending on the _mode_.  Recognized modes are:
  #
  # <tt>:columns_across</tt>::         _items_ will be placed in columns,
  #                                    flowing from left to right.  If given,
  #                                    _option_ is the number of columns to be
  #                                    used.  When absent, columns will be
  #                                    determined based on _wrap_at_ or a
  #                                    default of 80 characters.
  # <tt>:columns_down</tt>::           Identical to <tt>:columns_across</tt>,
  #                                    save flow goes down.
  # <tt>:uneven_columns_across</tt>::  Like <tt>:columns_across</tt> but each
  #                                    column is sized independently.
  # <tt>:uneven_columns_down</tt>::    Like <tt>:columns_down</tt> but each
  #                                    column is sized independently.
  # <tt>:inline</tt>::                 All _items_ are placed on a single line.
  #                                    The last two _items_ are separated by
  #                                    _option_ or a default of " or ".  All
  #                                    other _items_ are separated by ", ".
  # <tt>:rows</tt>::                   The default mode.  Each of the _items_ is
  #                                    placed on its own line.  The _option_
  #                                    parameter is ignored in this mode.
  #
  # Each member of the _items_ Array is passed through ERb and thus can contain
  # their own expansions.  Color escape expansions do not contribute to the
  # final field width.
  #
  def render
    return "" if items.empty?

    case mode
    when :inline
      list_inline_mode
    when :columns_across
      list_columns_across_mode
    when :columns_down
      list_columns_down_mode
    when :uneven_columns_across
      list_uneven_columns_mode
    when :uneven_columns_down
      list_uneven_columns_down_mode
    else
      items.map { |i| "#{i}\n" }.join
    end
  end

  private

  def render_list_items(items)
    items.to_ary.map do |item|
      item = String(item)
      template = ERB.new(item, nil, "%")
      template_renderer = HighLine::TemplateRenderer.new(template, self, highline)
      template_renderer.render
    end
  end

  def list_inline_mode
    end_separator = option || " or "

    if items.size == 1
      items.first
    else
      items[0..-2].join(", ") + "#{end_separator}#{items.last}"
    end
  end

  def list_columns_across_mode
    rows = padded_items.each_slice(col_count)

    rows.map { |row| row.join(row_join_string) + "\n" }.join
  end

  def list_columns_down_mode
    cols = padded_items.each_slice(row_count).to_a

    rows = transpose(cols)

    rows.map { |row| row.compact.join(row_join_string) + "\n" }.join
  end

  def list_uneven_columns_mode
    col_max = option || items.size
    col_max.downto(1) do |column_count|
      rows      = items.each_slice(column_count)

      widths = get_col_widths(rows, column_count)

      if column_count == 1 or # last guess
        inside_line_size_limit?(widths) or # good guess
        option # defined by user
        return pad_uneven_rows(rows, widths)
      end
    end
  end

  def pad_uneven_rows(rows, widths)
    rows.map do |row|
      row.zip(widths).map do |field, i|
        pad_field(field, i)
      end.join(row_join_string) + "\n"
    end.join
  end

  def pad_field(field, pad_size)
    "%-#{pad_size + (field.to_s.length - actual_length(field))}s" % field
  end

  def get_col_widths(rows, col_count)
    cols = transpose(rows)
    get_segment_widths(cols, col_count)
  end

  def get_row_widths(cols, row_count)
    get_segment_widths(cols, row_count)
  end

  def get_segment_widths(lines, segment_count)
    widths = Array.new(segment_count, 0)
    lines.each_with_index do |line, line_ix|
      line.each do |col|
        size = actual_length(col)
        widths[line_ix] = size if size > widths[line_ix]
      end
    end
    widths
  end

  def transpose(lines)
    first_line = Array(lines).shift
    first_line.zip(*lines)
  end

  def list_uneven_columns_down_mode
    col_max = option || items.size

    col_max.downto(1) do |column_count|
      row_count = (items.size / column_count.to_f).ceil
      columns   = items.each_slice(row_count)

      widths = get_row_widths(columns, column_count)

      if column_count == 1 or 
        inside_line_size_limit?(widths) or
        option
        return pad_uneven_cols(columns, widths)
      end
    end
  end

  def inside_line_size_limit?(widths)
    line_size = widths.inject(0) { |sum, n| sum + n + row_join_str_size }
    line_size <= line_size_limit + row_join_str_size
  end

  def pad_uneven_cols(columns, widths)
    list = ""
    columns.first.size.times do |index|
      list << columns.zip(widths).map { |column, width|
        field = column[index]
        pad_field(field, width)
      }.compact.join(row_join_string).strip + "\n"
    end
    list
  end

  def actual_length(text)
    HighLine::Wrapper.actual_length text
  end

  def items_max_length
    @items_max_length ||= max_length(items)
  end

  def max_length(items)
    items.map { |item| actual_length(item) }.max
  end

  def line_size_limit
    @line_size_limit ||= ( highline.wrap_at || 80 )
  end

  def row_join_string
    @row_join_string ||= "  "
  end

  def row_join_string=(string)
    @row_join_string = string
  end

  def row_join_str_size
    row_join_string.size
  end

  def get_col_count
    (line_size_limit + row_join_str_size) /
      (items_max_length + row_join_str_size)
  end

  def col_count
    option || get_col_count
  end

  def padded_items
    items.map do |item|
      pad_size = items_max_length - actual_length(item)
      item + (" " * pad_size)
    end
  end

  def row_count
    (items.count / col_count.to_f).ceil
  end
end