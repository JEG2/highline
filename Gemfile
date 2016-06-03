source "https://rubygems.org"

gem "rake", require: false
gem "rdoc", require: false

group :development, :test do
  gem "code_statistics", require: false
  gem "minitest", require: false
end

gem "codeclimate-test-reporter", group: :test, require: false
gem "simplecov", group: :test, require: false

group :development do
  gem 'pronto'
  gem 'pronto-reek', require: false
  gem 'pronto-rubocop', require: false
  gem 'pronto-poper', require: false

  # Using strict versions of flay and pronto-flay while
  # PR https://github.com/mmozuras/pronto-flay/pull/11/files
  # is not merged
  gem 'flay', '2.7.0'
  gem 'pronto-flay', '0.6.1', require: false
  gem 'flog'
end
