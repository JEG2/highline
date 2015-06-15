#coding: utf-8

class HighLine
  module SystemExtensions
    module JRuby
      def initialize_system_extensions
        require 'java'
        require 'readline'
        if JRUBY_VERSION =~ /^1.7/
          java_import 'jline.console.ConsoleReader'

          input = @input && @input.to_inputstream
          output = @output && @output.to_outputstream

          @java_console = ConsoleReader.new(input, output)
          @java_console.set_history_enabled(false)
          @java_console.set_bell_enabled(true)
          @java_console.set_pagination_enabled(false)
          @java_terminal = @java_console.getTerminal
        elsif JRUBY_VERSION =~ /^1.6/
          java_import 'java.io.OutputStreamWriter'
          java_import 'java.nio.channels.Channels'
          java_import 'jline.ConsoleReader'
          java_import 'jline.Terminal'

          @java_input = Channels.newInputStream(@input.to_channel)
          @java_output = OutputStreamWriter.new(Channels.newOutputStream(@output.to_channel))
          @java_terminal = Terminal.getTerminal
          @java_console = ConsoleReader.new(@java_input, @java_output)
          @java_console.setUseHistory(false)
          @java_console.setBellEnabled(true)
          @java_console.setUsePagination(false)
        end
      end
    end
  end
end