class Admin::AdminController < ActionController::Base
  before_filter :authenticate_admin!

  append_view_path(File.join(Rails.root, *%w[app slices]))

  protected

  def presenter_class(page_class)
    Object.const_get("#{page_class.name}Presenter")
  end
end

