class Admin::SnippetsController < Admin::AdminController
  layout 'admin'
  respond_to :json, :html

  def index
    respond_to do |format|
      format.html {}
      format.json do
        params[:per_page] = 50 unless params.include?(:per_page)
        @snippets = Snippet.by_key.paginate(params)
        render json: @snippets.as_json
      end
    end
  end

  def edit
    @snippet = Snippet.find(params[:id])
    render action: :form, layout: !request.xhr?
  end

  def update
    @snippet = Snippet.find(params[:id])
    @snippet.update_attributes(snippet_params)
    respond_to do |format|
      format.html {}
      format.json do
        render json: @snippet.as_json
      end
    end
  end

  private

  def snippet_params
    params.require(:snippet).permit(:key, :value)
  end
end

