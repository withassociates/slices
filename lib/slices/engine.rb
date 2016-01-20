module Slices
  class Engine < Rails::Engine
    initializer :autoload_slices, before: :set_autoload_paths do |app|
      Slices.autoload_slices(app, Rails.root)
    end

    initializer :active_mongoid_observers do
      config.mongoid.observers.concat [:page_observer, :asset_observer]
    end

    initializer :slices_precompile_hook do |app|
      app.config.assets.precompile += %w(slices/slices.css slices/slices.js)
    end

    config.after_initialize do
      Slices.load_slice_classes_into_object_space(Rails.root)
    end
  end

  def self.autoload_slices(app, root)
    slice_dirs = Dir.glob(File.expand_path('app/slices/*', root))
    app.config.autoload_paths.push(*slice_dirs.select { |f| File.directory?(f) })
  end

end
