#coding: utf-8

class HighLine
  module SystemExtensions
    module WindowsFiddle
      require "fiddle"

      module WinAPI
        include Fiddle
        Handle = RUBY_VERSION >= "2.0.0" ? Fiddle::Handle : DL::Handle
        Kernel32 = Handle.new("kernel32")
        Crt = Handle.new("msvcrt") rescue Handle.new("crtdll")

        def self._getch
          @@_m_getch ||= Function.new(Crt["_getch"], [], TYPE_INT)
          @@_m_getch.call
        end

        def self.GetStdHandle(handle_type)
          @@get_std_handle ||= Function.new(Kernel32["GetStdHandle"], [-TYPE_INT], -TYPE_INT)
          @@get_std_handle.call(handle_type)
        end

        def self.GetConsoleScreenBufferInfo(cons_handle, lp_buffer)
          @@get_console_screen_buffer_info ||=
            Function.new(Kernel32["GetConsoleScreenBufferInfo"], [TYPE_LONG, TYPE_VOIDP], TYPE_INT)
          @@get_console_screen_buffer_info.call(cons_handle, lp_buffer)
        end
      end
    end
  end
end