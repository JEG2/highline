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
			@flow      = :rows
			@question  = "?  "
			@proc_out  = false
			
			yield self if block_given?
		end

		attr_accessor :select_by
		attr_accessor :index
		attr_accessor :proc_out
		attr_accessor :question
		attr_accessor :flow
	
		def choice( name, &action )
			@items << [name, action]
		end

		def choices( *names, &action )
			names.each { |n| choice(n, &action) }
		end
		
		def display(  )
			indexed_items = case @index
			when :number
				@items.map { |c| "#{@items.index(c)+1}. #{c.first}" }
			when :letter
				l_index = "`"
				@items.map { |c| "#{l_index.succ!}. #{c.first}" }
			when :none
				@items.map { |c| "#{c.first}" }
			else
				@items.map { |c| "#{index} #{c.first}" }
			end
			
			"<%= list(#{indexed_items.inspect}, #{@flow.inspect}) %>"
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
			when :index_or_name
				by_index + by_name
			end
   		end

		def select( user_input )
			name, action = if user_input =~ /^\d+$/
				@items[user_input.to_i - 1]
			
			elsif @index != :letter

				@items.find { |c| c.first == user_input }
				
			else
				l_index = "`"
				index = @items.map { "#{l_index.succ!}" }.index(user_input)
				@items.find { |c| c.first == user_input } or @items[index]
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
