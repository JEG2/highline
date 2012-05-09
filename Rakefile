require "rdoc/task"
require "rake/testtask"
require "rubygems/package_task"

require "rubygems"

task :default => [:test]

Rake::TestTask.new do |test|
  test.libs       << "test"
  test.test_files =  [ "test/ts_all.rb"]
  test.verbose    =  true
  test.ruby_opts  << "-w"
end

Rake::RDocTask.new do |rdoc|
  rdoc.rdoc_files.include( "README.rdoc", "INSTALL",
                           "TODO", "CHANGELOG",
                           "AUTHORS", "COPYING",
                           "LICENSE", "lib/" )
  rdoc.main     = "README.rdoc"
  rdoc.rdoc_dir = "doc/html"
  rdoc.title    = "HighLine Documentation"
end

desc "Upload current documentation to Rubyforge"
task :upload_docs => [:rdoc] do
  sh "scp -r doc/html/* " +
     "bbazzarrakk@rubyforge.org:/var/www/gforge-projects/highline/doc/"
  sh "scp -r site/* " +
     "bbazzarrakk@rubyforge.org:/var/www/gforge-projects/highline/"
end

load(File.join(File.dirname(__FILE__), "highline.gemspec"))
Gem::PackageTask.new(SPEC) do |package|
  # do nothing:  I just need a gem but this block is required
end

desc "Show library's code statistics"
task :stats do
  require 'code_statistics'
  CodeStatistics.new( ["HighLine", "lib"], 
                      ["Functionals", "examples"], 
                      ["Units", "test"] ).to_s
end

desc "Add new files to Subversion"
task :add_to_svn do
  sh %Q{svn status | ruby -nae 'system "svn add \#{$F[1]}" if $F[0] == "?"' }
end
