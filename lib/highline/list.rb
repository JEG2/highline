class HighLine
  class List
    attr_reader :items, :cols, :list
    attr_reader :transpose_mode, :col_down_mode

    def initialize(items, options = {})
      @items          = items
      @transpose_mode = options.fetch(:transpose) { false }
      @col_down_mode  = options.fetch(:col_down)  { false }
      @cols           = options.fetch(:cols)      { 1 }
      build
    end

    def transpose
      first_row = @list[0]
      other_rows = @list[1..-1]
      @list = first_row.zip(*other_rows)
      self
    end

    def col_down
      slice_by_rows
      transpose
      self
    end

    def slice_by_rows
      @list = items_sliced_by_rows
      self
    end

    def slice_by_cols
      @list = items_sliced_by_cols
      self
    end

    def cols=(cols)
      @cols = cols
      build
    end

    private

    def build
      slice_by_cols
      transpose if transpose_mode
      col_down  if col_down_mode
      self
    end

    def items_sliced_by_cols
      items.each_slice(cols).to_a
    end

    def items_sliced_by_rows
      items.each_slice(row_count).to_a
    end

    def row_count
      (items.count / cols.to_f).ceil
    end
  end
end