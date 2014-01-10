class SetSlice < Slice
  include Mongoid::Document

  DEFAULT_SORT_FIELD = :created_at
  DEFAULT_SORT_DIRECTION = :desc

  field :per_page, type: Integer, default: 5
  field :sort_field, type: String, default: DEFAULT_SORT_FIELD
  field :sort_direction, type: String, default: DEFAULT_SORT_DIRECTION

  def prepare(params)
    @page_num = params[:page] || 1
  end

  def addable_entries?
    true
  end

  def editable_entries?
    true
  end

  def entry_type
    self.class.name.sub('SetSlice', '').underscore.to_sym
  end

  def entries
    sorted selected_by_type normal_or_set_page.children
  end

  def page_entries(params = {})
    entries.paginate(paginate_options(params))
  end

  def paginate_options(params)
    params.reverse_merge(page: @page_num, per_page: per_page)
  end

  def sort_field
    read_attribute(:sort_field) || DEFAULT_SORT_FIELD
  end

  def sort_direction
    read_attribute(:sort_direction) || DEFAULT_SORT_DIRECTION
  end


  private

  def sorted entries
    entries.send sort_direction, sort_field
  end

  def selected_by_type entries
    entries.where _type: entry_type.to_s.classify
  end
end