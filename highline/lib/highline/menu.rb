#!/usr/local/bin/ruby -w

# menu.rb
#
#  Created by Gregory Thomas Brown on 2005-05-10.
#  Copyright 2005 smtose.org. All rights reserved.

require "highline/question"

class HighLine
	class Menu < Question
		def initialize(  )
			super("Ignored", [ ], &nil)
			
			@items           = [ ]

			@index           = :number
			@index_suffix    = ". "
			@select_by       = :index_or_name
			@flow            = :rows
			@list_option     = nil
			@header          = nil
			@prompt          = "?  "
			@layout          = :list
			@shell           = false
			@nil_on_handled  = false
			
			yield self if block_given?
		end

		attr_accessor :index
		attr_accessor :index_suffix
		attr_accessor :select_by
		attr_accessor :flow
		attr_accessor :list_option
		attr_accessor :header
		attr_accessor :prompt
		attr_accessor :layout
		attr_accessor :shell
		attr_accessor :nil_on_handled
	
		def choice( name, &action )
			@items << [name, action]
		end

		def choices( *names, &action )
			names.each { |n| choice(n, &action) }
		end
		
		def layout=( new_layout )
			@layout = new_layout
			
			# Default settings.
			case @layout
			when :one_line, :menu_only
				@index = :none
				@flow  = :inline
			end
		end

   		def options(  )
   	 		by_index = if @index == :letter
				l_index = "`"
				@items.map { "#{l_index.succ!}" }
			else
				(1 .. @items.size).collect { |s| String(s) }
			end
    		by_name  = @items.collect { |c| c.first }

   	 		case @select_by
			when :index then
				by_index
			when :name
				by_name
			else
				by_index + by_name
			end
   		end

		def select( selection, details = nil )
			name, action = if selection =~ /^\d+$/
				@items[selection.to_i - 1]
			else
				l_index = "`"
				index = @items.map { "#{l_index.succ!}" }.index(selection)
				@items.find { |c| c.first == selection } or @items[index]
			end

			if not @nil_on_handled and not action.nil?
				if @shell
					action.call(name, details)
				else
					action.call(name)
				end
			elsif action.nil?
				name
			else
				nil
			end
		end

		def to_ary(  )
			case @index
			when :number
				@items.map do |c|
					"#{@items.index(c) + 1}#{@index_suffix}#{c.first}"
				end
			when :letter
				l_index = "`"
				@items.map { |c| "#{l_index.succ!}#{@index_suffix}#{c.first}" }
			when :none
				@items.map { |c| "#{c.first}" }
			else
				@items.map { |c| "#{index}#{@index_suffix}#{c.first}" }
			end
		end

		def to_str(  )
			case @layout
			when :list
				'<%= if @header.nil? then '' else "#{@header}:\n" end %>' +
				"<%= list( @menu, #{@flow.inspect},
				                  #{@list_option.inspect} ) %>" +
				"<%= @prompt %>"
			when :one_line
				'<%= if @header.nil? then '' else "#{@header}:  " end %>' +
				"<%= @prompt %>" +
				"(<%= list( @menu, #{@flow.inspect},
				                   #{@list_option.inspect} ) %>)" +
				"<%= @prompt[/\s*$/] %>"
			when :menu_only
				"<%= list( @menu, #{@flow.inspect},
				                  #{@list_option.inspect} ) %><%= @prompt %>"
			else
				@layout
			end
		end			
	end
end
