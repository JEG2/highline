# encoding: utf-8

source "https://rubygems.org"

gem "rake", require: false
gem "rdoc", require: false

group :development, :test do
  gem "code_statistics", require: false
  gem "minitest", require: false
end

# Reporting only at one ruby version of travis matrix (no repetition)
gem "codeclimate-test-reporter", group: :test, require: false

platform :ruby do
  # Running only on MRI
  gem "simplecov", group: :test
end

group :development do
  gem "pronto"
  gem "pronto-poper", require: false
  gem "pronto-reek", require: false
  gem "pronto-rubocop", require: false

  # Using strict versions of flay and pronto-flay while
  # PR https://github.com/mmozuras/pronto-flay/pull/11/files
  # is not merged
  gem "flay", "2.7.0"
  gem "flog"
  gem "pronto-flay", "0.6.1", require: false
end
