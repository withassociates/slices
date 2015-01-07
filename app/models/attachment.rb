class Attachment
  include Mongoid::Document
  include Slices::LocalizedFields

  belongs_to :asset

  embedded_in :object, polymorphic: true

  def as_json *args
    result = attributes.symbolize_keys.merge asset: asset.as_json

    localized_field_names.each do |name|
      result.merge!(name => send(name))
    end

    result
  end

end

