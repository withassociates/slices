class Admin::AdminController < SlicesController
  before_filter :authenticate_admin!

  protected

  def presenter_class(page_class)
    Object.const_get("#{page_class.name}Presenter")
  end
end

