saise 'aaaaa'
module Slices

  class I18nBackend
    include I18n::Backend::Simple::Implementation

    # Translates the given local and key. See the I18n API documentation for details.
    #
    # @return [Object] the translated key (usually a String)
    def translate(locale, key, options = {})
      content = super(locale, key, options.merge(fallback: true))
      if content.respond_to?(:html_safe)
        content.html_safe
      else
        content
      end
    end
  end
end

I18n.backend = I18n::Backend::Chain.new(
  Slices::I18n::Backend.new,
  I18n.backend
)
