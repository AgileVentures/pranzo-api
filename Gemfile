# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.0.0'

gem 'active_model_serializers', '~> 0.10.0'
gem 'aws-sdk-s3', require: false
gem 'bootsnap', '>= 1.4.2', require: false
gem 'devise_token_auth'
gem 'geocoder'
gem 'globalize'
gem 'image_processing', '~> 1.2'
gem 'pg', '>= 0.18', '< 2.0'
gem 'prawn'
gem 'prawn-svg'
gem 'puma', '~> 4.1'
gem 'rack-cors'
gem 'rails', '~> 6.0.2', '>= 6.0.2.2'
gem 'redis', '~> 4.0'
gem 'res_os_ruby'
gem 'rest-client'
gem 'rqrcode'
gem 'stripe-rails'
gem 'validate_url'

group :development, :test do
  gem 'factory_bot_rails'
  gem 'faker'
  gem 'pdf-inspector', require: 'pdf/inspector'
  gem 'pry-rails'
  gem 'rspec-rails'
  gem 'shoulda-matchers'
  gem 'stripe-ruby-mock', '~> 3.1.0.rc2', require: 'stripe_mock'
  gem 'timecop'
end

group :development do
  gem 'guard-rspec', require: false
  gem 'listen', '~> 3.7', '>= 3.7.1'
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end
