require 'spec_helper'

describe Admin::AdminsController, :type => :controller do

  before do
    sign_in_as_admin
  end

  context "on GET to :index" do
    it "adds current_admin property to admin documents" do
      get :index, format: :json
      expect(response.body).to include 'current_admin'
    end
  end

  context "on PUT to :update" do

    let :admin_params do
      {
        name: 'Updated Name',
        email: 'updated@withassociates.com',
        password: '',
        password_confirmation: ''
      }
    end

    let :admin_params_with_password do
      admin_params.merge({
        password: 'sekret',
        password_confirmation: 'sekret'
      })
    end

    let :admin_id do
      'abc'
    end

    let :admin do
      double(:admin).as_null_object
    end

    before do
      expect(Admin).to receive(:find).with(admin_id).and_return(admin)
    end

    context "with valid attributes" do
      before do
        expect(admin).to receive(:valid?).and_return(true)
      end

      it "does not update :password if is blank" do
        expect(admin).to receive(:update_attributes).with(
          {
            name: 'Updated Name',
            email: 'updated@withassociates.com',
          }.stringify_keys!
        )
        put :update, id: admin_id, admin: admin_params
      end

      it "updates :password if is present" do
        expect(admin).to receive(:update_attributes).with(admin_params_with_password.stringify_keys)
        put :update, id: admin_id, admin: admin_params_with_password
      end

      it "responds with a redirect" do
        put :update, id: admin_id, admin: admin_params
        expect(response.code).to eq '302'
      end

    end

    context "with in valid attributes" do
      before do
        expect(admin).to receive(:valid?).and_return(false)
      end

      it "renders the :show template" do
        put :update, id: admin_id, admin: admin_params
        is_expected.to render_template :show
      end

    end

  end

  context "on DELETE to :destroy" do
    let :current_admin do
      Admin.where(email: 'hello@withassociates.com').first
    end

    context "when deleting the current_admin" do
      it "returns a 409 error" do
        delete :destroy, id: current_admin.id, format: :json
        expect(response.code).to eq '409'
      end
    end
  end
end

