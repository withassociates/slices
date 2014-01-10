require 'spec_helper'

describe "The Asset Library", js: true do

  before do
    create_asset_fixtures
    sign_in_as_admin
    visit admin_assets_path
  end

  it "shows the correct count" do
    page.should have_content "Showing all 2 assets, latest first"
  end

  it "shows the correct number of thumbnails" do
    page.should have_css ".asset-library-item", count: 2
  end

end

