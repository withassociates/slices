class <%= page_name.classify %>ShowSlice < Slice
  restricted_slice

  # A "show slice" is handy if every page in a set will have the same
  # fields defined up on them, and no slices will be involved in the
  # display of the page. Append it to the set page's entry_content.slices.
  #
  # Here's an example of how to give the slice the ability to access the
  # copy field on the <%= page_name %>'s content document:
  #
  # attr_reader :copy
  #
  # def prepare(params)
  #   @copy = page.content[:copy]
  # end
  #
  # Don't forget to add each field to the as_json method in <%= page_name %>.rb
  # if you want to be able to edit the fields in the admin UI.
end

