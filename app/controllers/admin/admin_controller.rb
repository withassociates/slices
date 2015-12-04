class Admin::AdminController < ActionController::Base
  before_filter :authenticate_admin!

  append_view_path(File.join(Rails.root, *%w[app slices]))

  protected

  def presenter_class(page_class)
    Object.const_get("#{page_class.name}Presenter")
  end

  def authenticate_admin!
    redirect_to new_admin_session_path unless admin_signed_in?
  end

  def admin_signed_in?
    current_admin.present?
  end
  helper_method :admin_signed_in?

  def current_admin
    @current_admin ||= session[:admin_id] && Admin.where(id: session[:admin_id]).first
  end
  helper_method :current_admin
end
