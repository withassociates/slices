class AssetObserver < Mongoid::Observer
  def after_validation(record)
    record.update_page_cache
  end
end

