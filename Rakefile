require "rake/testtask"
require "rubygems/package_task"
require "bundler/gem_tasks"
require "code_statistics"

require "rubygems"

task default: [:test]

Rake::TestTask.new do |test|
  test.libs       = %w[lib test]
  test.verbose    = true
  test.warning    = true
  test.test_files = FileList["test/test*.rb"]
end

Gem::PackageTask.new(SPEC) do |package|
  # do nothing:  I just need a gem but this block is required
end

desc "Run some interactive acceptance tests"
task :acceptance do
  load "test/acceptance/acceptance.rb"
end
