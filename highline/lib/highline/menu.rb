# menu.rb
#
#  Created by Gregory Thomas Brown on 2005-05-10.
#  Copyright 2005 smtose.org. All rights reserved.
class HighLine
	class Menu
		def initialize()
			@items = []
			@index = :number
			@select_by = :index_or_name
			yield self if block_given?
		end
	
		def choice(name,&action)
			@items << [name,action]
		end

		def find(name)
			@items.find { |c| c.first == name }
		end
	
		def remove(name)
			choice = find(name)
			@items.delete(choice) unless choice.nil?
		end
		
		def display
			menu_string = ""
			if self.index.eql?(:number)
				menu_string << (@items.map { |c| "#{self.items.index(c)+1}. #{c.first}\n" }).to_s
			elsif self.index.eql?(:letter)
				l_index = "`"
				menu_string << (@items.map { |c| "#{l_index.succ!}. #{c.first}\n" }).to_s
			elsif self.index.eql?(:none)
				menu_string << (@items.map { |c| "- #{c.first}\n" }).to_s
			end
			return menu_string
		end

   		def options()
    	 		options = []
    	 		by_index = lambda { (1 .. @items.size).collect { |s| String(s) } }
     			by_name  = lambda { self.items.collect { |c| c.first } }
    	 		options = case self.select_by
        	        	when :index then
        	           	  by_index.call
        	        	when :name
        	           	  by_name.call
        	         	when :index_or_name
        	           	  by_index.call + by_name.call
        	        end
     			return options
   		end

		def select(user_input)
			
			if user_input =~ /^\d+$/ 
				tuple = @items[user_input.to_i-1]
				tuple.last.nil? ? tuple.first : tuple.last.call
			
			else
      				tuple = find(user_input)
				tuple.last.nil? ? tuple.first : tuple.last.call
    			end
		end
			

		def choices( *names, &action )
    			names.each { |n| choice(n, &action) }
		end

		attr_reader :items
		attr_accessor :select_by
		attr_accessor :index
	end				
end
