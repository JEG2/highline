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

  def list_columns_mode_prepare
    width = option || (limit + 2) / (max_length + 2)

    padded_items = items.map do |item|
      pad = max_length + (item.to_s.length - actual_length(item))
      "%-#{pad}s" % item
    end
    row_count = (padded_items.size / width.to_f).ceil

    [width, padded_items, row_count]
  end

  def list_columns_across_mode
    option, items, row_count =
      list_columns_mode_prepare

    rows = Array.new(row_count) { Array.new }
    items.each_with_index do |item, index|
      rows[index / option] << item
    end

    rows.map { |row| row.join("  ") + "\n" }.join
  end

  def list_columns_down_mode
    option, items, row_count =
      list_columns_mode_prepare

    columns = Array.new(option) { Array.new }
    items.each_with_index do |item, index|
      columns[index / row_count] << item
    end

    list = ""
    columns.first.size.times do |index|
      list << columns.map { |column| column[index] }.
                      compact.join("  ") + "\n"
    end
    list
  end

  def list_uneven_columns_mode
    if option.nil?
      limit = highline.wrap_at || 80
      items.size.downto(1) do |column_count|
        row_count = (items.size / column_count.to_f).ceil
        rows      = Array.new(row_count) { Array.new }
        items.each_with_index do |item, index|
          rows[index / column_count] << item
        end

        widths = Array.new(column_count, 0)
        rows.each do |row|
          row.each_with_index do |field, column|
            size           = actual_length(field)
            widths[column] = size if size > widths[column]
          end
        end

        if column_count == 1 or
           widths.inject(0) { |sum, n| sum + n + 2 } <= limit + 2
          return rows.map { |row|
            row.zip(widths).map { |field, i|
              "%-#{i + (field.to_s.length - actual_length(field))}s" % field
            }.join("  ") + "\n"
          }.join
        end
      end
    else
      row_count = (items.size / option.to_f).ceil
      rows      = Array.new(row_count) { Array.new }
      items.each_with_index do |item, index|
        rows[index / option] << item
      end

      widths = Array.new(option, 0)
      rows.each do |row|
        row.each_with_index do |field, column|
          size           = actual_length(field)
          widths[column] = size if size > widths[column]
        end
      end

      return rows.map { |row|
        row.zip(widths).map { |field, i|
          "%-#{i + (field.to_s.length - actual_length(field))}s" % field
        }.join("  ") + "\n"
      }.join
    end
  end

  def list_uneven_columns_down_mode
    if option.nil?
      limit = highline.wrap_at || 80
      items.size.downto(1) do |column_count|
        row_count = (items.size / column_count.to_f).ceil
        columns   = Array.new(column_count) { Array.new }
        items.each_with_index do |item, index|
          columns[index / row_count] << item
        end

        widths = Array.new(column_count, 0)
        columns.each_with_index do |column, i|
          column.each do |field|
            size      = actual_length(field)
            widths[i] = size if size > widths[i]
          end
        end

        if column_count == 1 or
           widths.inject(0) { |sum, n| sum + n + 2 } <= limit + 2
          list = ""
          columns.first.size.times do |index|
            list << columns.zip(widths).map { |column, width|
              field = column[index]
              "%-#{width + (field.to_s.length - actual_length(field))}s" %
              field
            }.compact.join("  ").strip + "\n"
          end
          return list
        end
      end
    else
      row_count = (items.size / option.to_f).ceil
      columns   = Array.new(option) { Array.new }
      items.each_with_index do |item, index|
        columns[index / row_count] << item
      end

      widths = Array.new(option, 0)
      columns.each_with_index do |column, i|
        column.each do |field|
          size      = actual_length(field)
          widths[i] = size if size > widths[i]
        end
      end

      list = ""
      columns.first.size.times do |index|
        list << columns.zip(widths).map { |column, width|
          field = column[index]
          "%-#{width + (field.to_s.length - actual_length(field))}s" % field
        }.compact.join("  ").strip + "\n"
      end
      return list
    end
  end

  def actual_length(text)
    HighLine::Wrapper.actual_length text
  end

  def max_length
    @max_length ||=
      items.map { |item| actual_length(item) }.max
  end

  def limit
    @limit ||= ( highline.wrap_at || 80 )
  end
end