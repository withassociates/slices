class Admin::PagesController < Admin::AdminController
  layout 'admin'

  respond_to :html, only: [:new, :show, :create]
  respond_to :json, only: [:show, :update, :destroy]
  respond_to :text, only: [:show]

  before_filter :find_all_slices, only: :update

  def new
    @page = Page.new(parent_id: params[:parent_id]) # TODO: change parent_id to path
    @layouts = Layout.all
    respond_with(:admin, @page) do |format|
      format.html { render layout: !request.xhr? }
    end
  end

  def create
    page_attrs = params[:page].merge(author: current_admin)
    @page = new_page_class.make(page_attrs)
    @layouts = [['Default', 'default']]

    respond_with(:admin, @page) do |format|
      format.html { redirect_to admin_page_path(@page) }
    end
  end

  def show
    page = Page.find(params[:id])
    @page = presenter_class(page.class).new(page)
    @layout = Layout.new(page.layout)

    respond_with(:admin, @page) do |format|
      format.json do
        render json: as_json_for_page(page)
      end
      format.hbs do
        hbs_path = if params[:slice]
                     File.join(params[:slice], 'templates', params[:template])
                   else
                     params[:template]
                   end
        render hbs_path
      end
    end
  rescue Mongoid::Errors::DocumentNotFound
    redirect_to admin_site_maps_path
  end

  def update
    @page = Page.find(params[:id])
    if entry_page?
      params[:page][:set_slices] = params[:page].delete(:slices)
    end

    @page.update_attributes(params[:page])

    if @page.valid?
      render json: as_json_for_page(@page)
    else
      render json: @page.errors.as_json, status: 422
    end
  end

  def destroy
    @page = Page.find(params[:id])
    @page.destroy
    respond_to do |format|
      format.html { redirect_to admin_site_maps_path }
      format.json { head :no_content }
    end
  end

  def index
    render json: Page.all
  end

  private
    def new_page_class
      params[:type].nil? ? Page : Object.const_get(params[:type].camelize)
    end

    def as_json_for_page(page)
      json_options = {}
      if entry_page?
        json_options[:only] = :slices
        json_options[:slice_embed] = :set_slices
      end
      page.as_json(json_options)
    end

    def entry_page?
      params.has_key?(:entries)
    end

    def find_all_slices
      Slices::AvailableSlices.all
    end
end

