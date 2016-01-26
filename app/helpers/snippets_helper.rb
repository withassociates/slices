module SnippetsHelper

  # Renders a snippet on the page
  #
  #   snippet 'address'
  #   # => "54B Downham Road"
  #
  # @param  [String]     key                         Snippet key to lookup
  # @return [String]
  #
  def snippet(key = nil)
    Snippet.find_for_key(key)
  end

  # Renders a localized snippet for the current locale
  #
  #   localized_snippet 'address'
  #   # => "54B Downham Road"
  #
  # @param  [String]     key                         Snippet key to lookup
  # @return [String]
  #
  def localized_snippet(key = nil)
    snippet("#{I18n.locale}.#{key}")
  end
end
