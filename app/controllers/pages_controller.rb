class PagesController < SlicesController

  caches_page :virtual_error_pages

  def virtual_error_pages
    role = Page.role_for_status(params[:status])
    if role
      render_page(Page.find_virtual(role), 200)  # page is only cached if status is 200
    else
      raise Page::NotFound.new(request.path)
    end
  end

  def create
    page = Page.find_by_path(request.path)
    raise Page::NotFound unless page.active?
    slice = post_slice(page)
    if slice.handle_post(params)
      slice.set_success_message(flash)
      redirect_to(slice.redirect_url)
    else
      render_page(page)
    end
  end

  def show
    page = nil
    benchmark 'Page.find_by_path' do
      page = Page.find_by_path(request.path)
      raise Page::NotFound unless page.active?
    end
    render_page(page)
  end

  private
    def post_slice(page)
      page.slices.detect { |s| s.respond_to?(:handle_post) }.tap do |slice|
        slice.nil? && (raise RuntimeError.new("page can't handle POST data"))
        slice.setup({
          renderer: self,
          current_page: page
        })
      end
    end
end
