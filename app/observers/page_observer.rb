class PageObserver < Mongoid::Observer
  attr_accessor :record

  def around_save(record)
    self.record = record

    if attachment_assets_changed?
      attachment_assets = record.attachment_assets
      to_update = record.assets + attachment_assets
      record.assets = attachment_assets
    end

    yield

    if page_changed? || did_attachment_assets_change?
      (to_update || record.assets).each do |asset|
        asset.reload
        asset.save
      end
    end

    true # Not returning true causes problems with Mongoid 2.5.1
  end

  def attachment_assets_changed?
    @did_attachment_assets_change = record.attachment_asset_ids != record.asset_ids
  end

  def did_attachment_assets_change?
    @did_attachment_assets_change
  end

  def page_changed?
    record.path_changed?
  end
end

