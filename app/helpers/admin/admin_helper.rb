# This module provides common helper methods for the CMS admin interface
#
module Admin::AdminHelper
  # A list of css classes for the admin layout's body tag
  #
  # @!visibility private
  def body_class_from_controller
    [controller.controller_name.dasherize].tap do |classes|
      if controller.respond_to?(:devise_controller?) && controller.devise_controller?
        classes << 'devise'
      end
    end.join(' ')
  end

  # The set type of the current page
  #
  # @!visibility private
  def page_set_type(page)
    page.sets.first.try(:entry_type)
  end

  # Render a navigation link in the top nav
  #
  # @!visibility private
  def admin_nav_link(controller, url = false, selected_url = false)
    controller_name = controller.gsub(/ /, "_").downcase.pluralize
    url = "/admin/#{controller_name}" unless url

    css = nil
    if selected_url && request.env['REQUEST_URI'] =~ /#{selected_url}/
      css = "active"
    elsif request.env['REQUEST_URI'] =~ /#{url}/
      css = "active"
    end
    content_tag(:li, link_to(controller, url), class: css, id: "admin-nav-#{controller_name.dasherize}")
  end

  # Render custom navigation if template exists
  #
  # @!visibility private
  def render_custom_navigation
    if lookup_context.template_exists?('admin/shared/_custom_navigation')
      render 'admin/shared/custom_navigation'
    end
  end

  # Render custom links if a template exists
  #
  # @!visibility private
  def render_custom_links
    if lookup_context.template_exists?('admin/shared/_custom_links')
      render 'admin/shared/custom_links'
    end
  end

  # The CMS admin page title, fall back to 'Slices CMS' if there is no @page
  #
  # @!visibility private
  def cms_title
    @page.try(:name) || "Slices CMS"
  end
end
