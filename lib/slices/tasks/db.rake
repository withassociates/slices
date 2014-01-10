module Slices
  module Tasks
    def self.create_indexes
      [
        Slices.gem_path + '/app/models/**/*.rb',
        Rails.root.join('app/slices/**/*.rb')
      ].each do |pattern|
        Dir.glob(pattern).each do |file|
          model = determine_model(file)
          if model
            model.create_indexes
            Logger.new($stdout).info("Generated indexes for #{model}")
          end
        end
      end
    end

    def self.determine_model(file)
      segments = file[0 .. -4].split('/')
      start = if segments.include?('slices')
                segments.rindex('slices') + 2
              else
                segments.rindex('models') + 1
              end
      model_path = segments[start .. -1]
      klass = model_path.map { |path| path.camelize }.join('::').constantize
      if klass.ancestors.include?(::Mongoid::Document) && !klass.embedded
        return klass
      end
    end
  end
end

namespace :slices do
  namespace :db do
    desc "Create indexes for slices models"
    task create_indexes: "db:mongoid:create_indexes" do
      Slices::Tasks.create_indexes
    end
  end

  namespace :migrate do
    desc "Rename description field to meta_description"
    task meta_description: :environment do
      Page.collection.update({},
        {'$rename' => {'description' => 'meta_description'}},
        multi: true)
    end
  end
end
