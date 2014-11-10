class Attachment
  include Mongoid::Document
  include Mongoid::Attributes::Dynamic
  include Slices::LocalizedFields

  belongs_to :asset

  embedded_in :object, polymorphic: true

  def as_json *args
    result = attributes.symbolize_keys.except(:_id, :_type, :asset_id).merge(
      _id: id.to_s,
      asset: asset.as_json,
      asset_id: asset_id.to_s,
    )

    localized_field_names.each do |name|
      result.merge!(name => send(name))
    end

    result
  end

end

