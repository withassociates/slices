require 'active_support/inflector'

module Slices
  module Asset
    module Rename
      class UnsupportedStorage < ::StandardError; end

      def self.run(file, new_file_name)
        klass = ('Slices::Asset::Rename::' + file.options[:storage].to_s.classify).constantize
        klass.new(file, new_file_name).run
      rescue NameError
        raise UnsupportedStorage,
          "Renaming files with '#{file.options[:storage]}' is not supported"
      end

      class Base
        attr_accessor :file, :new_file_name

        def initialize(file, new_file_name)
          self.file = file
          self.new_file_name = new_file_name
        end

        def run
          (file.styles.keys + [:original]).each do |style|
            next unless file.exists?(style)
            rename(style)
          end
        end

        def rename(style)
          @old_path = file.path(style)
          @new_path = File.join(File.dirname(@old_path), @new_file_name)
        end
      end

      class Filesystem < Base
        def rename(style)
          super
          File.rename(@old_path, @new_path)
        end
      end

      class Fog < Base
        def new_path
          @new_path[1 .. -1]
        end

        def rename(style)
          super
          file = directory.files.new(key: @old_path)
          file.copy(
            directory.key,
            @new_path,
            {'x-amz-acl' => 'public-read'}
          )
          file.destroy
        end

        def directory
          @directory ||= file.send(:directory)
        end
      end
    end

  end
end
