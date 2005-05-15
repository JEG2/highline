#!/usr/local/bin/ruby -w

# menu.rb
#
#  Created by Gregory Thomas Brown on 2005-05-10.
#  Copyright 2005 smtose.org. All rights reserved.

class HighLine
	class Menu
		def initialize(  )
			@items     = [ ]
			@index     = :number
			@select_by = :index_or_name
			@proc_out  = false
			
			yield self if block_given?
		end

		attr_accessor :select_by
		attr_accessor :index
		attr_accessor :proc_out
	
		def choice( name, &action )
			@items << [name, action]
		end

		def choices( *names, &action )
			names.each { |n| choice(n, &action) }
		end
		
		def display(  )
			case @index
			when :number
				@items.map { |c| "#{@items.index(c)+1}. #{c.first}\n" }.join
			when :letter
				l_index = "`"
				@items.map { |c| "#{l_index.succ!}. #{c.first}\n" }.join
			else
				@items.map { |c| "- #{c.first}\n" }.join
			end
		end

   		def options(  )
   	 		by_index = (1 .. @items.size).collect { |s| String(s) }
    		by_name  = @items.collect { |c| c.first }

   	 		case @select_by
			when :index then
				by_index
			when :name
				by_name
			when :index_or_name
				by_index + by_name
			end
   		end

		def select( user_input )
			name, action = if user_input =~ /^\d+$/
				@items[user_input.to_i - 1]
			else
				@items.find { |c| c.first == user_input }
			end

			if @proc_out and not action.nil?
				action.call
			elsif action.nil?
				name
			else
				nil
			end
		end
	end				
end
