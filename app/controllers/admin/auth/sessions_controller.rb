class Admin::Auth::SessionsController < ::Devise::SessionsController
  layout 'admin'
  helper 'admin/admin'
end
