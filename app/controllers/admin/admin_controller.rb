class Admin::AdminController < ActionController::Base
  before_filter :authenticate_admin!
  around_filter :set_locale

  append_view_path(File.join(Rails.root, *%w[app slices]))

  protected

  def presenter_class(page_class)
    Object.const_get("#{page_class.name}Presenter")
  end

  private

  def request_locale
    params[:locale]
  end

  def set_locale
    I18n.with_locale(request_locale || I18n.default_locale) do
      yield
    end
  end
end

