class Attachment
  include Mongoid::Document

  belongs_to :asset

  def as_json *args
    attributes.as_json.merge asset: asset.as_json
  end

end

