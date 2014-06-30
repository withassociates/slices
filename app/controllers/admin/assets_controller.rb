class Admin::AssetsController < Admin::AdminController
  require 'zip'

  layout 'admin'
  respond_to :json, :html

  def index
    respond_to do |format|
      format.html {}
      format.json do
        params[:per_page] = 50 unless params.include?(:per_page)
        @assets = Asset.search_for(params[:search]).paginate(params)
        render json: @assets.as_json
      end
    end
  end

  def download
    @assets = Asset.search_for(params[:search])
    timestamp = Time.now.strftime("%d%m%y-%H%M%S")
    tmp_zip = Tempfile.new("assets-#{timestamp}.zip")

    Zip::OutputStream.open(tmp_zip) { }

    Zip::File.open(tmp_zip.path, Zip::File::CREATE) do |zipfile|
      @assets.each do |asset|
        zipfile.add(asset.file_file_name,
                    asset.file.path(:original))
      end
    end

    send_file(
      tmp_zip.path, type: 'application/zip', filename: 'assets.zip'
    )

  ensure
    tmp_zip.close
  end

  def create
    @asset = Asset.make asset_attrs

    respond_with do |format|
      format.json { render json: @asset }
    end
  end

  def update
    @asset = Asset.find params[:id]
    @asset.update_attributes asset_attrs

    respond_with @asset do |format|
      format.json { render json: @asset }
    end
  end

  def destroy
    asset = Asset.find(params[:id])
    asset.soft_destroy!
    respond_to do |format|
      format.html { redirect_to admin_assets_path }
      format.json { render json: true }
    end
  end

  private

  def asset_attrs
    attrs = params[:asset] || {}
    if file = params[:file]
      file = URI(file.gsub(' ', '+')) if file.is_a?(String)
      attrs[:file] = file
    end
    attrs
  end

end
