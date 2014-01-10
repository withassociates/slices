require 'rails'
require 'bson'
require 'devise'
require 'mongo'
require 'mongoid'
require 'mongoid_paperclip'
require 'RedCloth'
require 'redcarpet'
require 'stringex'

require 'slices/paperclip'
require 'slices/version'

require 'mongo_search'
require 'ext/file_store_cache'

module Slices
  autoload :Config,                     'slices/config'
  autoload :CmsFormBuilder,             'slices/cms_form_builder'
  autoload :AvailableSlices,            'slices/available_slices'
  autoload :ContainerParser,            'slices/container_parser'
  autoload :GeneratorMacros,            'slices/generator_macros'
  autoload :HasSlices,                  'slices/has_slices'
  autoload :HasAttachments,             'slices/has_attachments'
  autoload :Renderer,                   'slices/renderer'
  autoload :PositionHelper,             'slices/position_helper'
  autoload :SplitDateTimeField,         'slices/split_date_time_field'
  autoload :Tree,                       'slices/tree'

  module Asset
    autoload :Maker,                    'slices/asset/maker'
    autoload :Rename,                   'slices/asset/rename'
  end

  def self.gem_path
    File.expand_path('..', File.dirname(__FILE__))
  end

  def self.load_slice_classes_into_object_space(root)
    Dir.glob(File.join(root, 'app', 'slices', '**/*.rb')).each do |file|
      constant = File.basename(file, '.rb').camelize
      Object.const_get(constant)
    end
  end

  def self.test_environment?
    Rails.env.test? && Rails.root.to_s == Slices.gem_path
  end

end

require 'slices/slices_engine' if defined?(Rails)
require 'slices/i18n'
require 'slices/will_paginate_mongoid'
require 'slices/will_paginate'
require 'set_link_renderer'

if Rails.env.development?
  Slices::Config.use_snippets!
end
if Rails.env.test? || Rails.env.development?
  require 'standard_tree'
end

Mime::Type.register_alias 'text/plain', :hbs
Time::DATE_FORMATS.merge!(
  day_month_year: '%d %B %Y'
)
