class <%= page_name.classify %>Presenter < PagePresenter
  include EntryPresenter

  # We need to tell the admin UI which fields to show when presenting a
  # table of entries in the admin UI. Each key in the column hash should
  # be a symbol matching the name of one of the fields defined on the
  # page.
  #
  # The hash's values (e.g. 'Date Published') will be used for the
  # column headings in the admin UI.

  @columns = {
    name: 'Name',
    # published_at: 'Date Published'
  }
  class << self
    attr_reader :columns
  end

<%- if options.with_entry_templates? -%>
  def main_extra_template
    '<%= file_name %>/<%= page_name %>_main'
  end

  def meta_extra_template
    '<%= file_name %>/<%= page_name %>_meta'
  end
<%- else -%>
  # If you want to display extra information while editing or creating a
  # page (i.e. in the admin UI's side bar) you'll need to define some
  # .hbs files, and then tell the CMS to use them by uncommenting these
  # methods.

  # def main_extra_template
  #   '<%= file_name %>/<%= page_name %>_main'
  # end

  # def meta_extra_template
  #   '<%= file_name %>/<%= page_name %>_meta'
  # end
<%- end -%>

  # The CMS needs to know how to present the data stored on a page;
  # it's not always good enough just to convert it to a string and
  # render it into the page. You can access the page through the @source
  # variable.

  def name
    @source.name.blank? ? "(name isn't set)" : @source.name
  end

end

