require 'spec_helper'

describe Admin::PagesController, type: :controller do

  before do
    sign_in_as_admin
  end

  context "in development mode" do
    before do
      allow(Page).to receive(:find_by_id!).and_return(page)
    end

    let :id do
      BSON::ObjectId.new
    end

    let :page do
      double(:page).as_null_object
    end

    it "loads all slices before udpating a page" do
      expect(Slices::AvailableSlices).to receive(:all)
      post :update, id: id, page: {}
    end

  end
end

