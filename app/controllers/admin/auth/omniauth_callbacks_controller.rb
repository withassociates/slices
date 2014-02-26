class Admin::Auth::OmniauthCallbacksController < ::Devise::OmniauthCallbacksController
  layout 'admin'
  helper 'admin/admin'

  def google_apps
    email = request.env['omniauth.auth']['info']['email']
    @admin = Admin.find_for_google_apps(email)

    if @admin.persisted?
      sign_in_and_redirect @admin, event: :authentication
    else
      redirect_to new_admin_session_path
    end
  end
end
