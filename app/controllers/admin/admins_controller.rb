class Admin::AdminsController < Admin::AdminController
  layout 'admin'

  respond_to :json, :html

  def index
    admins = Admin.all
    if params.has_key?(:search) && params[:search].present?
      admins = admins.text_search(params[:search])
    end

    respond_to do |format|
      format.html
      format.json do
        params[:per_page] = 50 unless params.include?(:per_page)
        params[:per_page] = params[:per_page].to_i
        render json: jsonify_with_current_admin(admins.paginate(params))
      end
    end
  end

  def new
    @admin = Admin.new
    render action: :show
  end

  def create
    @admin = Admin.new(params[:admin])
    if @admin.save
      redirect_to admin_admins_path
    else
      render action: :show
    end
  end

  def show
    @admin = Admin.find(params[:id])
    respond_with(@admin)
  end

  def update
    admin_params = params[:admin]
    if admin_params[:password].blank?
      admin_params.delete(:password)
      admin_params.delete(:password_confirmation)
    end
    @admin = Admin.find(params[:id])
    @admin.update_attributes(admin_params)
    if @admin.valid?
      redirect_to admin_admin_path(@admin)
    else
      render action: :show
    end
  end

  def destroy
    admin = Admin.find(params[:id])
    if admin == current_admin
      render text: '', status: 409
    else
      admin.destroy
      respond_to do |format|
        format.html { redirect_to admin_admins_path }
        format.json { render json: true }
      end
    end
  end

  private

  def jsonify_with_current_admin(paginated_admins)
    paginated_admins.as_json.tap do |json|
      json[:items] = json[:items].as_json(current_admin: current_admin)
    end
  end
end
