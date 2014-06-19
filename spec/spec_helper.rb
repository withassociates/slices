# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV['RAILS_ENV'] ||= 'test'
require 'bundler'
Bundler.setup

require File.expand_path('../../config/environment', __FILE__)
require 'rspec/rails'
require 'capybara/rails'
require 'capybara/poltergeist'
require 'rack_utf8_fix'

Paperclip.options[:logger] = Rails.logger
Paperclip.options[:log] = true

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join('spec/support/**/*.rb')].each { |f| require f }

# Setup slices to use view/slice/site fixtures
SlicesController.prepend_view_path(Rails.root.join(*%w[spec fixtures views]))
SlicesController.prepend_view_path(Rails.root.join(*%w[spec fixtures slices]))

Slices::Config.use_snippets!

Capybara.default_selector = :css
Capybara.default_wait_time = ENV['CI'] ? 60 : 5
Capybara.default_driver = :rack_test
Capybara.javascript_driver = :poltergeist

RSpec.configure do |config|
  config.mock_with :rspec
  config.order = 'random'

  config.extend AssetMacros
  config.include Mongoid::Matchers, type: :model
  config.include GeneratorHelpers
  config.include AssetHelpers
  config.include RequestHelpers, type: :request
  config.include ControllerHelpers, type: :controller
  config.include Capybara::DSL, type: :request

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
      FileUtils.rm_rf Rails::root.join *%w[public system spec]
    when :fog
      Asset.all.map &:destroy
    end
    DatabaseCleaner.clean
  end

end

Capybara.register_driver :poltergeist do |app|
  Capybara::Poltergeist::Driver.new(app, {
    debug: false,
    inspector: true
  })
end

module Capybara::Node::Matchers

  def enabled?
    self[:disabled].nil?
  end

  def disabled?
    !enabled?
  end

end
