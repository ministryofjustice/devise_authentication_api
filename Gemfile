source 'https://rubygems.org'

gem 'rails', '4.0.2'

gem 'rails-api'
gem 'mongoid', '~> 4.0.0', github: 'mongoid/mongoid', ref: 'df4580b'

gem 'devise'

# To use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.0.0'

# To use Jbuilder templates for JSON
# gem 'jbuilder'

# Use unicorn as the app server
# gem 'unicorn'

# Deploy with Capistrano
# gem 'capistrano', :group => :development

# To use debugger
# gem 'ruby-debug19', :require => 'ruby-debug'

group :development, :test do
  gem 'rspec'
  gem 'rspec-rails'
  gem 'pry'
end

group :development do
  gem 'rake'
end

group :test do
  gem 'rack-test'
  gem 'guard-rspec'
  gem 'database_cleaner'
end


# production webserver
gem 'unicorn'
