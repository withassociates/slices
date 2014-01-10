class <%= class_name %>Slice < SetSlice
  restricted_slice

<%- if options.with_identical_entries? -%>
  def addable_entries?
    false
  end

  def editable_entries?
    false
  end
<%- end -%>
end

