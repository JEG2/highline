# coding: utf-8

class HighLine
  class Paginator
    attr_reader :highline

    def initialize(highline)
      @highline = highline
    end

    #
    # Page print a series of at most _page_at_ lines for _output_.  After each
    # page is printed, HighLine will pause until the user presses enter/return
    # then display the next page of data.
    #
    # Note that the final page of _output_ is *not* printed, but returned
    # instead.  This is to support any special handling for the final sequence.
    #
    def page_print(text)
      return text unless highline.page_at

      lines = text.scan(/[^\n]*\n?/)
      while lines.size > highline.page_at
        highline.puts lines.slice!(0...highline.page_at).join
        highline.puts
        # Return last line if user wants to abort paging
        return (["...\n"] + lines.slice(-2,1)).join unless continue_paging?
      end
      return lines.join
    end

    #
    # Ask user if they wish to continue paging output. Allows them to type "q" to
    # cancel the paging process.
    #
    def continue_paging?
      command = highline.new_scope.ask(
        "-- press enter/return to continue or q to stop -- "
      ) { |q| q.character = true }
      command !~ /\A[qQ]\Z/  # Only continue paging if Q was not hit.
    end
  end
end