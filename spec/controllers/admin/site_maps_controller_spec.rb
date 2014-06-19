require 'spec_helper'

describe Admin::SiteMapsController, type: :controller do

  before do
    sign_in_as_admin
  end

  context "on GET to :index" do
    let(:home) { double(:home) }
    let(:virtual) { double(:virtual) }

    before do
      expect(Page).to receive(:home).and_return(home)
      expect(Page).to receive(:virtual).and_return(virtual)

      get :index
    end

    it "responds with success" do
      expect(response).to be_success
    end

    it "assigns to :page" do
      expect(assigns(:pages)).to be
    end

    it "assigns to :page" do
      expect(assigns(:virtuals)).to eq virtual
    end
  end

  context "on PUT to :update" do
    let(:sitemap) { 'sitemap' }

    before do
      expect(SiteMap).to receive(:rebuild).with(sitemap)
      expect(controller).to receive(:expire_fragment).with(/navigation/)

      put :update, sitemap: sitemap
    end

    it "responds with success" do
      expect(response).to be_success
    end

  end

end

