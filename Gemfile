source 'https://rubygems.org'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~>4.0'
# Use postgresql as the database for Active Record
gem 'pg'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.0'
# bundle exec rake doc:rails generates the API under doc/api.

# Use ActiveModel has_secure_password
#gem 'bcrypt', '~> 3.1.7'
gem 'bcrypt'

#gem 'devise'
gem 'devise_token_auth'
gem 'doorkeeper'

gem 'validates_email_format_of'
gem 'date_validator'

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]

gem 'rack-cors', require: 'rack/cors'
gem 'fog'
gem 'fog-aws'
gem 'cancancan', '~> 1.10'
gem 'pubnub'
gem 'aws-ses', '~> 0.6.0', require: 'aws/ses'
gem 'swagger-blocks'
gem 'aws-sdk', '< 2.0'


# Use Capistrano for deployment
group :development do
  gem 'capistrano', '3.4.0'
  gem 'capistrano-rails'
  gem 'capistrano-bundler'
  gem 'capistrano-rvm'
  gem 'capistrano3-nginx'
end

group :test do
  gem 'minitest-rails'
  gem 'minitest-reporters'
  gem 'factory_girl_rails'
  gem 'simplecov', require: false
  gem 'faker'
end