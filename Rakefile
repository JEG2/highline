require "rdoc/task"
require "rake/testtask"
require "rubygems/package_task"
require "bundler/gem_tasks"
require "code_statistics"

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
                           "TODO", "Changelog.md",
                           "AUTHORS", "COPYING",
                           "LICENSE", "lib/" )
  rdoc.main     = "README.rdoc"
  rdoc.rdoc_dir = "doc/html"
  rdoc.title    = "HighLine Documentation"
end

Gem::PackageTask.new(SPEC) do |package|
  # do nothing:  I just need a gem but this block is required
end
