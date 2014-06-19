require 'spec_helper'

describe "Searching the Asset Library", type: :request, js: true do

  before do
    create_asset_fixtures
    sign_in_as_admin
    visit admin_assets_path
    fill_in "assets-search", with: "lady"
  end

  it "updates the count correctly" do
    expect(page).to have_content "Showing 1 matching asset"
  end

  it "finds the right assets" do
    expect(page).to have_css ".asset-library-item", count: 1
    expect(page.body).to include "lady_bird.jpg"
    expect(page.body).not_to include "pepper-pot.jpg"
  end

end

