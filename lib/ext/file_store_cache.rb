module ActiveSupport
  module Cache
    class FileStore < Store

      silence_warnings do
        UNESCAPE_FILENAME_CHARS = /%([0-9A-F]{2})/
      end

      private

      def file_path_key(path)
        fname = path[cache_path.size, path.size].split(File::SEPARATOR, 4).last
        fname.gsub(UNESCAPE_FILENAME_CHARS){|match| $1.hex.chr }
      end
    end
  end
end

