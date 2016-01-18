# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV['RAILS_ENV'] ||= 'test'
require 'bundler'
Bundler.setup

require File.expand_path('../dummy/config/environment.rb',  __FILE__)
require 'rspec/rails'
require 'capybara/rails'
require 'support/standard_tree'

Paperclip.options[:logger] = Rails.logger
Paperclip.options[:log] = true

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
SLICES_GEM_ROOT = Pathname.new File.expand_path('.')
Dir[SLICES_GEM_ROOT.join('spec/support/**/*.rb')].each { |f| require f }

# Setup slices to use view/slice/site fixtures

Slices::Config.use_snippets!

Capybara.default_selector = :css
Capybara.default_wait_time = ENV['CI'] ? 60 : 5
Capybara.default_driver = :rack_test

RSpec.configure do |config|
  config.mock_with :rspec
  config.order = 'random'

  config.extend AssetMacros
  config.include GeneratorHelpers
  config.include AssetHelpers
  config.include RequestHelpers, type: :request
  config.include ControllerHelpers, type: :controller
  config.include Capybara::DSL, type: :request

  # Added for Rspec 3.0
  config.infer_spec_type_from_file_location!
  config.expose_current_running_example_as :example

  # Hook in database cleaner
  config.before do
    DatabaseCleaner.orm = 'mongoid'
    DatabaseCleaner.strategy = :truncation
    DatabaseCleaner.start
    Asset.attachment_definitions[:file][:url] =
      '/system/spec/:attachment/:mon_year/:id/:style/:filename'
  end

  config.after do
    # Delete uploaded assets
    case Paperclip::Attachment.default_options[:storage].to_sym
    when :filesystem
      FileUtils.rm_rf Rails::root.join(*%w[public system spec])
    when :fog
      Asset.all.map(&:destroy)
    end
    DatabaseCleaner.clean
  end

end

