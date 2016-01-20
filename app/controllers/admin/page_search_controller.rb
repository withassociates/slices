class Admin::PageSearchController < Admin::AdminController
  layout 'admin'

  respond_to :json, only: [:show]

  def show
    @query = params[:query]
    @pages = Page.where(name: Regexp.new(@query, true), role: nil).limit(5)
    render json: @pages.uniq.as_json
  end
end
