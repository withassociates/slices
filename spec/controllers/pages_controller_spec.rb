require 'spec_helper'

describe PagesController, type: :controller do
  context "GET :show" do
    let :page do
      Page.new(
        external_url: 'http://www.example.com',
        active: true
      )
    end

    it "redirects to the external url" do
      expect(Page).to receive(:find_by_path).and_return(page)
      get :show, path: nil
      expect(response).to redirect_to 'http://www.example.com'
    end
  end
end
