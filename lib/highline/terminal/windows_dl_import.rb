class HighLine
  module SystemExtensions
    module WindowsDlImport
      require "dl/import"

      module WinAPI
        if defined?(DL::Importer)
          # Ruby 1.9
          extend DL::Importer
        else
          # Ruby 1.8
          extend DL::Importable
        end
        begin
          dlload "msvcrt", "kernel32"
        rescue DL::DLError
          dlload "crtdll", "kernel32"
        end
        extern "unsigned long _getch()"
        extern "unsigned long GetConsoleScreenBufferInfo(unsigned long, void*)"
        extern "unsigned long GetStdHandle(unsigned long)"

        # Ruby 1.8 DL::Importable.import does mname[0,1].downcase so FooBar becomes fooBar
        if defined?(getConsoleScreenBufferInfo)
          alias_method :GetConsoleScreenBufferInfo, :getConsoleScreenBufferInfo
          module_function :GetConsoleScreenBufferInfo
        end
        if defined?(getStdHandle)
          alias_method :GetStdHandle, :getStdHandle
          module_function :GetStdHandle
        end
      end
    end
  end
end
