class SlicesController < ActionController::Base
  include ActiveSupport::Benchmarkable

  protect_from_forgery

  # rescue_from Exception, with: :render_error
  # rescue_from Page::NotFound, with: :render_not_found

  append_view_path(File.join(Rails.root, *%w[app slices]))

  define_callbacks :render_page, terminator: "response_body"

  def self.should_raise_exceptions?
    Rails.application.config.consider_all_requests_local
  end

  protected

  def render_not_found(exception)
    raise exception if self.class.should_raise_exceptions?
    render_not_found!(exception)
  end

  def render_not_found!(exception)
    logger.warn "404: #{request.path} :: #{request.params.inspect}"
    render_page(Page.find_virtual('not_found'), 404)
  end

  def render_error(exception)
    raise exception if self.class.should_raise_exceptions?
    logger.warn "500: #{request.path} :: #{request.params.inspect}"
    render_page(Page.find_virtual('error'), 500)
  end

  def admin_signed_in?
    current_admin.present?
  end
  helper_method :admin_signed_in?

  def current_admin
    @current_admin ||= session[:admin_id] && Admin.where(id: session[:admin_id]).first
  end
  helper_method :current_admin

  private

  def render_page(page, status = 200)
    @page = page

    run_callbacks :render_page do
      ordered_slices = nil
      benchmark 'Page.ordered_slices' do
        ordered_slices = page_or_parent_slices
      end
      @slice_renderer = Slices::Renderer.new(
        controller:   self,
        current_page: @page,
        params:       params,
        slices:       ordered_slices
      )
      render text: '', layout: page_layout(@page), status: status
    end
  end

  def page_or_parent_slices
    @page.entry? ? @page.parent.ordered_set_slices : @page.ordered_slices
  end

  def page_layout(page)
    page.layout
  end
end

