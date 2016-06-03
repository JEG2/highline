class HighLine
  class Menu < Question
    class Item
      attr_reader :name, :text, :help, :action

      #
      # @param name [String] The name that is matched against the user input
      # @param text: [String] The text that displays for that choice (defaults to name)
      # @param help: [String] help, see above (not sure how it works)
      # @param action: [Block] a block that gets called when choice is selected
      #
      def initialize(name, attributes)
        @name = name
        @text = attributes[:text] || @name
        @help = attributes[:help]
        @action = attributes[:action]
      end

      def item_help
        return {} unless help
        { name.to_s.downcase => help }
      end
    end
  end
end