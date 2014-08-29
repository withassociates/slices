class Snippet
  include Mongoid::Document

  field :key
  field :value
  index({ key: 1 })

  scope :by_key, ascending(:key)

  # Finds the value of a snippet as a html_safe string
  #
  #   Snippet.find_for_key 'address'
  #   # => "54B Downham Road"
  #
  # @param  [String]     key                         Snippet key to lookup
  # @return [String]
  #
  def self.find_for_key(key)
    find_by(key: key).value.html_safe
  rescue Mongoid::Errors::DocumentNotFound
  end

  def as_json(*args)
    {
      id: id.to_s,
      key: key,
      value: value,
    }
  end
end
