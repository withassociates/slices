class Admin::EntriesController < Admin::AdminController
  layout 'admin'

  respond_to :json, :html

  def index
    @page = Page.find params[:page_id]

    respond_to do |format|
      format.html do
        @columns = entry_presenter_class.columns
        @options = {
          sort_field: sort_field,
          sort_direction: sort_direction
        }
      end
      format.json do
        render json: fetch_entries.as_json
      end
    end
  end


  private

  def fetch_entries
    presented paginated searched sorted raw_entries
  end

  def presented entries
    entries.dup.tap do |entries|
      entries.each_with_index do |entry, index|
        entries[index] = entry_presenter_class.new entry
      end
    end
  end

  def paginated entries
    if sort_field != :position
      params[:per_page] = 50 unless params.include?(:per_page)
      params[:per_page] = params[:per_page].to_i

      entries.paginate params
    else
      entries.paginate per_page: entry_class.count
    end
  end

  def searched entries
    if params[:search].present?
      entries.text_search params[:search]
    else
      entries
    end
  end

  def sorted entries
    entries.send sort_direction, sort_field
  end

  def raw_entries
    entry_class.entries
  end

  def sort_direction
    set_slice.sort_direction
  end

  def sort_field
    set_slice.sort_field
  end

  def entry_class
    entry_type.to_s.camelize.constantize
  end

  def entry_type
    @page.entry_types.first
  end

  def set_slice
    @page.sets.first
  end

  def entry_presenter_class
    presenter_class entry_class
  end
end
