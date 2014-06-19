require 'spec_helper'

describe "Creating a child page", type: :request, js: true do

  before do
    home, @parent = StandardTree.build_minimal
    StandardTree.add_complex(home, @parent)
    sign_in_as_admin
  end

  let :new_page_name do
    'New Page'
  end

  context "with no errors" do

    before do
      visit "/admin/pages/new?parent_id=#{@parent.id}"
      within '#new_page' do
        fill_in 'Name', with: new_page_name
        select 'Default', from: 'Layout'
      end
      click_on 'Create Page'
    end

    it "sets the page name field to 'New Page'" do
      expect(page).to have_field 'meta-name', with: new_page_name
    end

    it "sets the permalink to 'new-page'" do
      # This is a new page, so the 'advanced options' pane should already be open.
      expect(page).to have_field 'meta-permalink', with: 'new-page'
    end

    context "saving the page" do
      before do
        click_on 'Save changes'
      end

      it "updates the view on site link" do
        expect(page).to have_xpath("//a[@href='/parent/new-page']")
      end
    end

    context "viewing the site map" do
      before do
        visit '/admin/site_maps'
      end

      it "adds the new page to the sitemap" do
        css = "li[rel='#{@parent.id}'] ol li div h2" # check that New Page is a child of Parent
        expect(page).to have_css css, text: new_page_name
      end
    end

  end
end
