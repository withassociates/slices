require File.expand_path('../lib/slices/version', __FILE__)

Gem::Specification.new do |s|
  s.name        = 'slices'
  s.version     = Slices::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ['With Associates']
  s.email       = ['hello@withassociates.com']
  s.homepage    = 'http://slices.withassociates.com'
  s.summary     = 'Slices CMS, from With Associates'
  s.description = 'A Rails CMS that can be embedded within your own site.'
  s.license     = 'MIT'

  s.required_ruby_version     = '>= 2.0.0'

  s.add_dependency 'devise'            , '~> 2.2.8'
  s.add_dependency 'highline'          , '~> 1.6.0'
  s.add_dependency 'mongoid'           , '> 4.0.0', '< 5.0.0'
  s.add_dependency 'mongoid-observers' , '~> 0'
  s.add_dependency 'mongoid-paperclip' , '~> 0'
  s.add_dependency 'rails'             , '~> 4.2'
  s.add_dependency 'redcarpet'         , '~> 3.0.0'
  s.add_dependency 'RedCloth'          , '~> 4.2.9'
  s.add_dependency 'stringex'          , '~> 1.4.0'
  s.add_dependency 'will_paginate_mongoid', '~> 2.0'

  src_files           = Dir['{app,lib}/**/*']
  template_files      = Dir['public/slices/templates/*.hbs']
  config_files        = %w[config/routes.rb] + Dir['config/initializers/*.rb']
  documentation_files = %w[CHANGELOG.md README.md]
  excluded_files      = Dir['app/slices/**/*'] + %w[app/views/layouts/default.html.erb]

  s.files = src_files + template_files + config_files + documentation_files - excluded_files

  s.require_path = 'lib'
end
