# encoding: utf-8

source "https://rubygems.org"

git_source(:github) { |repo_name| "https://github.com/#{repo_name}" }

# Specify your gem's dependencies in tgem.gemspec
gemspec

# Reporting only at one ruby version of travis matrix (no repetition)
gem "codeclimate-test-reporter", group: :test, require: false

platform :ruby do
  # Running only on MRI
  gem "simplecov", group: :test
end

group :code_quality do
  gem "flog", require: false
  gem "pronto", require: false
  gem "pronto-flay", require: false
  gem "pronto-poper", require: false
  gem "pronto-reek", require: false
  gem "pronto-rubocop", require: false
end
