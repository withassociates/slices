class PagePresenter < Presenter
  def bson_id
    @source.id.to_s
  end

  def name
    @source.name
  end

  def editing_entry_content_slices?(entries)
    set_page? && (! entries.nil?)
  end

  def set_page?
    @source.set_page?
  end

  def main_template
    'page_main'
  end

  def meta_template
    'page_meta'
  end

  def main_extra_template
    'page_main_extra'
  end

  def meta_extra_template
    'page_meta_extra'
  end

  def main_extra_templates
    [main_extra_template]
  end

  def meta_extra_templates
    [meta_extra_template]
  end

  def breadcrumbs
    [@source] + @source.ancestors
  end

  def children
    @source.children
  end

  def as_json(options={})
    json = {
      '_id' => @source.id.to_s,
      'url' => "/admin/pages/#{@source.id}"
    }
    self.class.columns.each do |key, val|
      json[key.to_s] = send(key)
    end
    json
  end

end

