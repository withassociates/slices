module Slices
  module Tasks

    def self.remove_all_unused_styles
      Asset.all.each do |asset|
        remove_unused_styles(asset)
      end
    end

    def self.remove_unused_styles(asset)
      asset.remove_attribute :dimensions

      used_styles = asset.file_dimensions.symbolize_keys.keys << :original
      styles_to_clear = asset.file.styles.keys - used_styles
      asset.file.clear(*styles_to_clear)
      asset.save
    end
  end
end

namespace :slices do
  namespace :assets do

    desc "Mark assets for reprocessing"
    task reprocess: :environment do
      Asset.update_all(file_dimensions: {})
    end

    desc "Remove unused asset styles"
    task remove_unused_styles: :environment do
      Slices::Tasks.remove_all_unused_styles
    end
  end
end

