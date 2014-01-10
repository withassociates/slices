WillPaginate::Collection.class_eval do
  def as_json(*args)
    {
      current_page: current_page,
      per_page: per_page,
      total_entries: total_entries,
      total_pages: total_pages,
      items: to_a
    }
  end
end

