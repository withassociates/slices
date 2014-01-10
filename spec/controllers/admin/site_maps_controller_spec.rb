require 'spec_helper'

describe Admin::SiteMapsController do

  before do
    sign_in_as_admin
  end

  context "on GET to :index" do
    let(:home) { stub(:home) }
    let(:virtual) { stub(:virtual) }

    before do
      Page.should_receive(:home).and_return(home)
      Page.should_receive(:virtual).and_return(virtual)

      get :index
    end

    it "responds with success" do
      response.should be_success
    end

    it "assigns to :page" do
      assigns(:pages).should be
    end

    it "assigns to :page" do
      assigns(:virtuals).should eq virtual
    end
  end

  context "on PUT to :update" do
    let(:sitemap) { 'sitemap' }

    before do
      SiteMap.should_receive(:rebuild).with(sitemap)
      controller.should_receive(:expire_fragment).with(/navigation/)

      put :update, sitemap: sitemap
    end

    it "responds with success" do
      response.should be_success
    end

  end

end

