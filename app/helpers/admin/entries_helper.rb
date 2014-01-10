# This module provides helper methods for entries in the CMS admin.
#
module Admin::EntriesHelper
  include Admin::AdminHelper

  # Create a link for adding a new entry
  #
  # @!visibility private
  def link_to_add_entry page
    url = new_admin_page_path parent_id: @page.id, type: page_set_type(page)
    raw link_to 'Add Entry', url, class: 'button add', id: 'add-entry'
  end
end
