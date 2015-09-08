source 'https://rubygems.org'

gemspec
gem 'fog-aws'

group :development, :test do
  gem 'byebug', platforms: [:ruby_20, :ruby_21]
  gem 'debugger', platforms: [:ruby_19]
  gem 'capybara', '~> 2.3.0'
  gem 'database_cleaner', '~> 0.9.1'
  gem 'pry-rails', '~> 0.2.2'
  gem 'rspec-rails', '~> 3.2.0'
  gem 'poltergeist'
end

group :test do
  gem 'launchy', '~> 2.1.2'
  gem 'ammeter'
end

group :assets do
  gem 'jquery-rails', '~> 2.1.4'
  gem 'sass-rails', '~> 3.2.5'
  gem 'uglifier', '~> 1.3.0'
end
