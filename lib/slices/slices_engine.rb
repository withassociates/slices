module Slices
  class Engine < Rails::Engine; end

  def self.autoload_slices(app, root)
    slice_dirs = Dir.glob(File.expand_path('app/slices/*', root))
    app.config.autoload_paths.push(*slice_dirs.select { |f| File.directory?(f) })
  end

  # We need to add the app's own app/slices/* directories to the load
  # path so that slices created within the application are automatically
  # detected. This means that we need a Railtie as well as an engine, as
  # an engine's initializer can't add autoload_paths that aren't scoped
  # within the engine itself (for some stupid reason).
  class Railtie < Rails::Railtie
    initializer :autoload_slices, before: :set_autoload_paths do |app|
      Slices.autoload_slices(app, Rails.root)
    end

    initializer :active_mongoid_observers do
      config.mongoid.observers.concat [:page_observer, :asset_observer]
    end

    initializer :slices_will_paginate_active_view, after:  'will_paginate.action_view' do
      load Slices.gem_path + '/lib/set_link_renderer.rb'
    end

    initializer :slices_precompile_hook do |app|
      app.config.assets.precompile += %w(slices/slices.css slices/slices.js)
    end

    config.after_initialize do
      Slices.load_slice_classes_into_object_space(Rails.root)
    end

    rake_tasks do
      root = Slices.gem_path + '/lib/'

      Dir[root + 'slices/tasks/*.rake'].each do |taskfile|
        load taskfile.sub root, ''
      end
    end

  end
end
