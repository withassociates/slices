module Slices
  module I18n

    class Backend
      module Implementation
        include ::I18n::Backend::Base, ::I18n::Backend::Flatten

        # This method receives a locale, a data hash and options for storing translations.
        # Should be implemented
        def store_translations(locale, data, options = {})
          raise NotImplementedError
        end

        def available_locales
          raise NotImplementedError
        end

        protected

        def lookup(locale, key, scope = [], options = {})
          key = normalize_flat_keys(locale, key, scope, options[:separator])
          Snippet.find_value_by_key("#{locale}.#{key}")
        end

      end

      include Implementation
    end

  end
end

