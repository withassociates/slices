require 'spec_helper'

describe "Deleting assets from the Library", type: :request, js: true do

  describe "a single asset" do
    before do
      create_asset_fixtures
      sign_in_as_admin
      visit admin_assets_path

      page.find('.asset-library-item:first-child').click
      auto_confirm_with true
      js_keydown 8
    end

    it "updates the count correctly" do
      expect(page).to have_content "Showing 1 asset"
    end

    it "removes the asset from view" do
      expect(page).to have_css ".asset-library-item", count: 1
    end

    it "really removes the asset" do
      visit admin_assets_path
      expect(page).to have_css ".asset-library-item", count: 1
    end
  end

  describe "multiple assets" do
    before do
      create_asset_fixtures
      sign_in_as_admin
      visit admin_assets_path

      page.find('.asset-library-item:first-child').click
      js_click_on('.asset-library-item:nth-child(2)', shift_key: true)

      auto_confirm_with true
      js_keydown 8

      wait_for_ajax
    end

    it "updates the count correctly" do
      expect(page).to have_content "No assets, yet…"
    end

    it "removes the asset from view" do
      expect(page).to have_no_css ".asset-library-item"
    end
  end

end

