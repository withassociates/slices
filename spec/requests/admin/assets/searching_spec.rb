require 'spec_helper'

describe "Searching the Asset Library", js: true do

  before do
    create_asset_fixtures
    sign_in_as_admin
    visit admin_assets_path
    fill_in "assets-search", with: "lady"
  end

  it "updates the count correctly" do
    page.should have_content "Showing 1 matching asset"
  end

  it "finds the right assets" do
    page.should have_css ".asset-library-item", count: 1
    page.body.should include "lady_bird.jpg"
    page.body.should_not include "pepper-pot.jpg"
  end

end

