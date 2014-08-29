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
end
