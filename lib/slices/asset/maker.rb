module Slices
  module Asset
    class Maker

      attr_accessor :args, :new_asset

      def self.run(args)
        new(args).run
      end

      def initialize(args)
        self.args = args
      end

      def create_new_asset
        ::Asset.create!(args)
      end

      def find_matching_asset(new_asset)
        ::Asset.where({
          file_fingerprint: new_asset.file_fingerprint, :_id.ne => new_asset.id
        }).first
      end

      def tempfile_stored_on_s3?
        Slices::Config.s3_storage? &&
          args[:file].is_a?(URI)
      end

      def s3_path
        s3_path = args[:file].path
        s3_path[s3_path.index(Slices::Config::S3_TEMPFILE_KEY_PREFIX) .. -1]
      end

      def delete_tempfile_from_s3
        directory = new_asset.file.send(:directory)
        directory.files.new(key: s3_path).destroy
      end

      def run
        self.new_asset = create_new_asset
        delete_tempfile_from_s3 if tempfile_stored_on_s3?
        matching_asset = find_matching_asset(new_asset)

        if matching_asset.present?
          new_asset.destroy
          matching_asset.soft_restore!
          matching_asset
        else
          new_asset
        end
      end
    end
  end
end
