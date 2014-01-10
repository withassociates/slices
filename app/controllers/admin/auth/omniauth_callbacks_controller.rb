class Admin::Auth::OmniauthCallbacksController < ::Devise::OmniauthCallbacksController
  layout 'admin'
  helper 'admin/admin'

  def google_apps
    domain = Slices::Config.google_apps_domain
    @admin = Admin.find_for_domain(domain)

    if @admin.persisted?
      sign_in_and_redirect @admin, event: :authentication
    else
      redirect_to new_admin_session_path
    end
  end
end
