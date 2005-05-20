#!/usr/local/bin/ruby -w

# menu.rb
#
#  Created by Gregory Thomas Brown on 2005-05-10.
#  Copyright 2005 smtose.org. All rights reserved.

require "highline/question"

class HighLine
	# 
	# Menu objects encapsulate all the details of a call to HighLine.choose().
	# Using the accessors and choice() and choices(), the block passed to
	# HighLine.choose() can detail all aspects of menu display and control.
	# 
	class Menu < Question
		#
		# Create an instance of HighLine::Menu.  All customization is done
		# through the passed block, which should call accessors and choice() and
		# choices() as needed to define the Menu.  Note that Menus are also
		# Questions, so all that functionality is available to the block as
		# well.
		# 
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

		attr_reader   :index
		attr_accessor :index_suffix
		attr_accessor :select_by
		attr_accessor :flow
		attr_accessor :list_option
		attr_accessor :header
		attr_accessor :prompt
		attr_reader   :layout
		attr_accessor :shell
		attr_accessor :nil_on_handled
		
		#
		# Add _name_ to the list of available menu items.  Menu items will be
		# displayed in the order they are added.
		# 
		# An optional _action_ can be associated with this name and if provided,
		# it will be called if the item is selected.  The result of the method
		# will be returned, unless _nil_on_handled_ is set (when you would get
		# +nil+ instead).  In _shell_ mode, a provided block will be passed the
		# command chosen and any details that followed the command.  Otherwise,
		# just the command is passed.
		# 
		def choice( name, &action )
			@items << [name, action]
		end
		
		#
		# A shortcut for multiple calls to the sister method choice().  <b>Be
		# warned:</b>  An _action_ set here will apply to *all* provided
		# _names_.
		# 
		def choices( *names, &action )
			names.each { |n| choice(n, &action) }
		end
		
		# 
		def index=( style )
			@index = style
			
			@index_suffix = " " if @index.is_a? String
		end
		
		# 
		# Setting a _layout_ with this method also adjusts some other attributes
		# of the Menu object, to ideal defaults for the chosen _layout_.  To
		# account for that, you probably want to set a _layout_ first in your
		# configuration block, if needed.
		# 
		# Accepted settings for _layout_ are:
		#
		# <tt>:list</tt>::         The default _layout_.  The _header_ if set
		#                          will appear at the top on its own line with
		#                          a trailing colon.  Then the list of menu
		#                          will follow.  Finally, the _prompt_ will be
		#                          used as the ask()-like question.
		# <tt>:one_line</tt>::     A shorter _layout_ that fits on one line.  
		#                          The _header_ comes first followed by a
		#                          colon and spaces, then the _prompt_ with menu
		#                          items between trailing parenthesis.
		# <tt>:menu_only</tt>::    Just the menu items, followed up by a likely
		#                          short _prompt_.
		# <i>any ERb String</i>::  Will be taken as the literal _layout_.  This
		#                          String can access <tt>@header</tt>, 
		#                          <tt>@menu</tt> and <tt>@prompt</tt>, but is
		#                          otherwise evaluated in the typical HighLine
		#                          context, to provide access to utilities like
		#                          HighLine.list() primarily.
		# 
		# If set to either :one_line, or :menu_only, _index_ will default to
		# <tt>:none</tt> and _flow_ will default to <tt>:inline</tt>.
		# 
		def layout=( new_layout )
			@layout = new_layout
			
			# Default settings.
			case @layout
			when :one_line, :menu_only
				@index = :none
				@flow  = :inline
			end
		end

		#
		# This method returns all possible options for auto-completion, based
		# on the settings of _index_ and _select_by_.
		# 
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

		#
		# This method processes the auto-completed user selection, based on the
		# rules for this Menu object.  It an action was provided for the 
		# selection, it will be executed as described in Menu.choice().
		# 
		def select( selection, details = nil )
			# Find the selected action.
			name, action = if selection =~ /^\d+$/
				@items[selection.to_i - 1]
			else
				l_index = "`"
				index = @items.map { "#{l_index.succ!}" }.index(selection)
				@items.find { |c| c.first == selection } or @items[index]
			end
			
			# Run or return it.
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
		
		#
		# Allows Menu objects to pass as Arrays, for use with HighLine.list().
		# This method returns all menu items to be displayed, complete with
		# indexes.
		# 
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
		
		#
		# Allows Menu to behave as a String, just like Question.  Returns the
		# _layout_ to be rendered, which is used by HighLine.say().
		# 
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
