class Snippet
  include Mongoid::Document

  field :key
  field :value
  index({ key: 1 })

  scope :by_key, ascending(:key)

  def self.find_value_by_key(key)
    where(key: key).first.try(:value)
  end

  def as_json(*args)
    {
      id: id.to_s,
      key: key,
      value: value,
    }
  end
end
