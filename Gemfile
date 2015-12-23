source 'https://rubygems.org'

gemspec
gem 'fog-aws'
gem 'ammeter'

group :development, :test do
  gem 'bundler'
  gem 'byebug'
  gem 'capybara'           , '~> 2.5'
  gem 'pry-rails'          #, '~> 0.2.2'
  gem 'rspec-rails'        , '~> 3.4'
  gem 'test-unit', platforms: [:ruby_22]
end

group :test do
  gem 'database_cleaner'   #, '~> 0.9.1'
  gem 'launchy'          #,'~> 2.1.2'
  gem 'poltergeist', '~> 1.7'
end

group :assets do
  gem 'jquery-rails' #, '~> 2.1.4'
  gem 'sass-rails'   #, '~> 3.2.5'
  gem 'uglifier'     #, '~> 1.3.0'
end
