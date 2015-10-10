HighLine
========

by James Edward Gray II

[![Build Status](https://travis-ci.org/JEG2/highline.svg?branch=master)](https://travis-ci.org/JEG2/highline)
[![Build status](https://ci.appveyor.com/api/projects/status/4p05fijpah77d28x/branch/master?svg=true)](https://ci.appveyor.com/project/JEG2/highline/branch/master)
[![Gem Version](https://badge.fury.io/rb/highline.svg)](https://badge.fury.io/rb/highline)
[![Code Climate](https://codeclimate.com/github/abinoam/highline/badges/gpa.svg)](https://codeclimate.com/github/JEG2/highline)
[![Test Coverage](https://codeclimate.com/github/abinoam/highline/badges/coverage.svg)](https://codeclimate.com/github/abinoam/highline/coverage)
[![Inline docs](http://inch-ci.org/github/JEG2/highline.svg?branch=master)](http://inch-ci.org/github/JEG2/highline)

Description
-----------

Welcome to HighLine.

HighLine was designed to ease the tedious tasks of doing console input and
output with low-level methods like ```gets``` and ```puts```. HighLine provides a
robust system for requesting data from a user, without needing to code all the
error checking and validation rules and without needing to convert the typed
Strings into what your program really needs.  Just tell HighLine what you're
after, and let it do all the work.

Documentation
-------------

See {HighLine} and {HighLine::Question} for documentation.

Usage
-----

```ruby

require 'highline'

# Basic usage

cli = HighLine.new
answer = cli.ask "What do you think?"
puts "You have answered: #{answer}"


# Default answer

cli.ask("Company?  ") { |q| q.default = "none" }


# Validation

cli.ask("Age?  ", Integer) { |q| q.in = 0..105 }
cli.ask("Name?  (last, first)  ") { |q| q.validate = /\A\w+, ?\w+\Z/ }


# Type conversion for answers:

cli.ask("Birthday?  ", Date)
cli.ask("Interests?  (comma sep list)  ", lambda { |str| str.split(/,\s*/) })


# Reading passwords:

cli.ask("Enter your password:  ") { |q| q.echo = false }
cli.ask("Enter your password:  ") { |q| q.echo = "x" }


# ERb based output (with HighLine's ANSI color tools):

cli.say("This should be <%= color('bold', BOLD) %>!")


# Menus:

cli.choose do |menu|
  menu.prompt = "Please choose your favorite programming language?  "
  menu.choice(:ruby) { say("Good choice!") }
  menu.choices(:python, :perl) { say("Not from around here, are you?") }
end
```

If you want to save up some characteres, you can inject/import HighLine methods on Kernel by doing the following. Be aware to avoid name collisions at the main namespace.

```ruby
require 'highline/import'

say "Now you can use #say directly"
```

For more examples see the examples/ directory of this project.

Requirements
------------

HighLine from version >= 1.7.0 requires ruby >= 1.9.3

Installing
----------

To install HighLine, use the following command:

```sh
$ gem install highline
```

(Add `sudo` if you're installing under a POSIX system as root)

If you're using [Bundler](http://bundler.io/), add this to your Gemfile:

```ruby
source "https://rubygems.org"
gem 'highline'
```

And then run:

```sh
$ bundle
```

If you want to build the gem locally, use the following command from the root of the sources:

```sh
$ rake package
```

You can also build and install directly:

```sh
$ rake install
```

Questions and/or Comments
-------------------------

Feel free to email [James Edward Gray II](mailto:james@grayproductions.net) or
[Gregory Brown](mailto:gregory.t.brown@gmail.com) with any questions.
