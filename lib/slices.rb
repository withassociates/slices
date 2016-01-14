require 'devise'
require 'devise/orm/mongoid'
require 'mongoid'
require 'mongoid_paperclip'
require 'will_paginate_mongoid'
require 'RedCloth'
require 'redcarpet'
require 'stringex'

require 'slices/paperclip'
require 'slices/version'

require 'mongo_search'
module Slices
  autoload :Config,                     'slices/config'
  autoload :CmsFormBuilder,             'slices/cms_form_builder'
  autoload :AvailableSlices,            'slices/available_slices'
  autoload :ContainerParser,            'slices/container_parser'
  autoload :GeneratorMacros,            'slices/generator_macros'
  autoload :HasSlices,                  'slices/has_slices'
  autoload :HasAttachments,             'slices/has_attachments'
  autoload :PageAsJSON,                 'slices/page_as_json'
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

end

require 'slices/engine' if defined?(Rails)
require 'slices/will_paginate'

Slices::Config.use_snippets!

Mime::Type.register_alias 'text/plain', :hbs
Time::DATE_FORMATS.merge!(
  day_month_year: '%d %B %Y'
)
