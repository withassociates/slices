# This module provides methods for the Site Map page.
#
module Admin::SiteMapsHelper
  include Admin::AdminHelper

  # Render a list of pages
  #
  # @!visibility private
  def list_pages(pages)
    pages.inject(''.html_safe) do |html, page|
      html << render(partial: page_partial(page), locals: {page: page} )
    end
  end

  # When partial to use when rendering a page
  #
  # @!visibility private
  def page_partial(page)
    page.set_page? ? 'set_page_li' : 'page_li'
  end

  # Is it possible to add entries to the set page?
  #
  # @!visibility private
  def addable_entries?(page)
    page.sets.first && page.sets.first.addable_entries?
  end

  # Is it possible to edit child entries of the set page?
  #
  # @!visibility private
  def editable_entries?(page)
    page.sets.first && page.sets.first.editable_entries?
  end

  # Create a link to add a child to the current page
  #
  # @!visibility private
  def link_to_add_child(page)
    url = new_admin_page_path parent_id: page.id
    raw link_to 'Add Child', url, class: 'button add-child'
  end

  # Create a link to delete the current page
  #
  # @!visibility private
  def link_to_delete(page)
    raw link_to 'Delete', admin_page_path(page),
      method: :delete,
      class: 'delete button',
      confirm: confirm_delete_message
  end

  # The message to display when confirming deletion of a page
  #
  # @!visibility private
  def confirm_delete_message
    <<-TEXT
      Are you sure you want to delete this page,
      all its children and all its slices and other content?
    TEXT
  end

  # Create a link to add an entry to the current page
  #
  # @!visibility private
  def link_to_add_entry(page)
    url = new_admin_page_path parent_id: page.id, type: page_set_type(page)
    raw link_to 'Add Entry', url, class: 'button add-child'
  end

  # Create a link to view all of the entries of the current page
  #
  # @!visibility private
  def link_to_all_entries(page)
    url = admin_page_entries_path page
    link_to 'View All', url, class: 'button'
  end

  # Create a link to edit the index template of the current page
  #
  # @!visibility private
  def link_to_edit_index_template(page)
    url = admin_page_path page
    link_to 'Edit Index Tempate', url, class: 'button'
  end

  # Create a link to edit the entry template of the current page
  #
  # @!visibility private
  def link_to_edit_entry_template(page)
    url = admin_page_path page, entries: 1
    link_to 'Edit Entry Template', url, class: 'button'
  end

  # Create a link to view the current page on the live site
  #
  # @!visibility private
  def link_to_view_page(page)
    return unless page.active?
    link_to 'View page on site', page.localized_path,
            class: 'view-page', target: '_blank'
  end

  # Return HTMl class names for a page
  #
  # @!visibility private
  def page_classes(page)
    classes = []
    classes << 'home' if page.home?
    classes << page._type.underscore.dasherize
    classes.join ' '
  end
end
