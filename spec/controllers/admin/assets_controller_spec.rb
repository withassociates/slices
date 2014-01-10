require 'spec_helper'

describe Admin::AssetsController do

  before do
    sign_in_as_admin
  end

  context "POST #create as :json" do
    context "with a file" do
      let :file do
        file_fixture
      end

      let :asset do
        Asset.new file: file
      end

      before do
        Asset.should_receive(:make).with(file: file).and_return(asset)
        post :create, file: file, format: :json
      end

      it "responds with a JSON description of the asset" do
        response.body.should == asset.to_json
      end
    end

    context "with a URL" do
      let :url do
        'https://exmaple.com/image 1.jpg'
      end

      it "converts the url string into a URI object" do
        uri = URI(url.gsub(' ', '+'))
        Asset.should_receive(:make).with(file: uri)

        post :create, file: url, format: :json
      end
    end
  end

  context "PUT #update as :json" do
    let :file do
      file_fixture
    end

    let :asset do
      Asset.new
    end

    before do
      Asset.should_receive(:find).with('123').and_return(asset)
      asset.should_receive(:update_attributes).with(file: file)

      put :update, id: '123', file: file, format: :json
    end

    it "responds with a JSON description of the asset" do
      response.body.should == asset.to_json
    end
  end

  context "DELETE #destroy as :json" do
    let :asset_id do
      'bson_id'
    end

    let :asset do
      double
    end

    before do
      Asset.should_receive(:find).with(asset_id).and_return(asset)
      asset.should_receive(:soft_destroy!)

      delete :destroy, id: asset_id, format: :json
    end

    it "is a success" do
      response.should be_success
    end

    it "is a json success" do
      response.body.should == 'true'
    end
  end
end

