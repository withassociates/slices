require 'spec_helper'

describe Admin::PagesController do

  before do
    sign_in_as_admin
  end

  context "in development mode" do
    before do
      Page.stub(:find_by_id!).and_return(page)
    end

    let :id do
      BSON::ObjectId.new
    end

    let :page do
      mock(:page).as_null_object
    end

    it "loads all slices before udpating a page" do
      Slices::AvailableSlices.should_receive(:all)
      post :update, id: id, page: {}
    end

  end
end

