class Admin::Auth::PasswordsController < ::Devise::PasswordsController
  layout 'admin'
  helper 'admin/admin'
end
