class Admin::SiteMapsController < Admin::AdminController
  layout 'admin'

  def index
    @pages = [Page.home]
    @virtuals = Page.virtual
  end

  def update
    SiteMap.rebuild(params[:sitemap])
    head :no_content
  end
end

