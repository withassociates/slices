class <%= page_name.classify %> < Page
<%= field_definitions %>

  def entry?
    true
  end

  def template
    "<%= file_name %>/views/show"
  end

  # Uncomment the as_json method if the page defines fields that are
  # shown in the admin UI. Pass a hash to merge() that contains each
  # field.
  #
  # def as_json(options = {})
  #   super.merge(published: published.to_s)
  # end
end
