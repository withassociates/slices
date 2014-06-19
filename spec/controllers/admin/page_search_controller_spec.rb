require 'spec_helper'

describe Admin::PageSearchController, type: :controller do

  describe "GET show :query = 'about', format: :json" do
    before do
      StandardTree.build_minimal
      ["About Us", "Abour Our Partners", "About Our Services"].each do |name|
        page = Page.make(
          name:        name,
          parent:      Page.home,
          active:      true,
          show_in_nav: true
        )
        page.slices.build({
          title:     "Title",
          container: "container_one",
          position:  0
        }, TitleSlice)
        page.save!
      end
      sign_in_as_admin
      get :show, query: "about", format: :json
    end

    it "responds with success" do
      expect(response).to be_success
    end

    it "assigns pages" do
      expect(assigns(:pages)).to eq(Page.where(name: /about/i, role: nil).limit(5))
    end

    it "responds with json" do
      expect(response.body).to eq(Page.where(name: /about/i, role: nil).limit(5).as_json({}).to_json)
    end
  end

end
