class Admin::SessionsController < Admin::AdminController
  layout 'admin'

  skip_before_filter :authenticate_admin!

  def new
    @session = Session.new
  end

  def create
    @session = Session.new(params[:session])

    if @session.valid?
      session[:admin_id] = @session.admin.id
      redirect_to admin_site_maps_path
    else
      render :new
    end
  end

  def destroy
    session.delete(:admin_id)
    redirect_to root_path
  end

end
