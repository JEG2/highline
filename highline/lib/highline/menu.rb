# menu.rb
#
#  Created by Gregory Thomas Brown on 2005-05-10.
#  Copyright 2005 smtose.org. All rights reserved.
class HighLine
	class Menu
		class Choice
	
			def initialize(name, action)
				@name = name
				@action = action
			end

			attr_reader :name
	
			def act()
				@action.call
			end
		end

		def initialize()
			@choices = []
			@index = :number
			@select_by = :index_or_name
			yield self if block_given?
		end
	
		def add(name,&action)
			@choices << Choice.new(name,action)
		end

		def find(name)
			@choices.find { |c| c.name == name }
		end
	
		def remove(name)
			choice = find(name)
			@choices.delete(choice) unless choice.nil?
		end
		
		def display
			menu_string = ""
			if self.index.eql?(:number)
				menu_string << (self.choices.map { |c| "#{self.choices.index(c)+1}. #{c.name}\n" }).to_s
			elsif self.index.eql?(:letter)
				l_index = "`"
				menu_string << (self.choices.map { |c| "#{l_index.succ!}. #{c.name}\n" }).to_s
			elsif self.index.eql?(:none)
				menu_string << (self.choices.map { |c| "- #{c.name}\n" }).to_s
			end
			return menu_string
		end

   		def options()
    	 		options = []
    	 		by_index = lambda { (1 .. self.choices.size).collect { |s| String(s) } }
     			by_name  = lambda { self.choices.collect { |c| c.name } }
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

		attr_reader :choices
		attr_accessor :select_by
		attr_accessor :index
	end				
end
