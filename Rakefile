require "rake/rdoctask"
require "rake/testtask"
require "rake/gempackagetask"

require "rubygems"

task :default => [:test]

Rake::TestTask.new do |test|
	test.libs << "test"
	test.test_files = [ "test/ts_all.rb" ]
	test.verbose = true
end

Rake::RDocTask.new do |rdoc|
	rdoc.main = "README"
	rdoc.rdoc_files.include( "README", "INSTALL",
	                         "TODO", "CHANGELOG",
	                         "AUTHORS", "COPYING",
	                         "LICENSE", "lib/" )
	rdoc.rdoc_dir = "doc/html"
	rdoc.title = "HighLine Documentation"
end

desc "Upload current documentation to Rubyforge"
task :upload_docs => [:rdoc] do
	sh "scp -r site/* " +
	   "bbazzarrakk@rubyforge.org:/var/www/gforge-projects/highline/"
	sh "scp -r doc/html/* " +
	   "bbazzarrakk@rubyforge.org:/var/www/gforge-projects/highline/doc/"
end

spec = Gem::Specification.new do |spec|
	spec.name = "highline"
	spec.version = "1.0.1"
	spec.platform = Gem::Platform::RUBY
	spec.summary = "HighLine is a high-level line oriented console interface."
	spec.files = Dir.glob("{examples,lib,test}/**/*.rb").
	                 delete_if { |item| item.include?("CVS") } +
	                 ["Rakefile", "setup.rb"]
	spec.test_suite_file = "test/ts_all.rb"
	spec.has_rdoc = true
	spec.extra_rdoc_files = %w{README INSTALL TODO CHANGELOG LICENSE}
	spec.rdoc_options << '--title' << 'HighLine Documentation' <<
	                     '--main'  << 'README'

	### Removed due to Windows' install problems ###
#	spec.add_dependency("termios", ">= 0.9.4")

	spec.require_path = 'lib'
	spec.autorequire = "highline"
	spec.author = "James Edward Gray II"
	spec.email = "james@grayproductions.net"
	spec.rubyforge_project = "highline"
	spec.homepage = "http://highline.rubyforge.org"
	spec.description = <<END_DESC
A "high-level line oriented" input/output library that grew out of my solution
to Ruby Quiz #29. This library attempts to make standard console input and
output robust and painless.
END_DESC
end

Rake::GemPackageTask.new(spec) do |pkg|
	pkg.need_zip = true
	pkg.need_tar = true
end

desc "Show library's code statistics"
task :stats do
	require 'code_statistics'
	CodeStatistics.new( ["HighLine", "lib"], 
	                    ["Functionals", "examples"], 
	                    ["Units", "test"] ).to_s
end
