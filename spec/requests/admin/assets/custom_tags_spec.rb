require 'spec_helper'

describe "Adding tags to an asset", type: :request, js: true do
  let! :asset do
    Asset.make file: file_fixture
  end

  it "updates the asset’s tags" do
    sign_in_as_admin
    visit admin_assets_path
    hover_over_asset_thumb
    click_on 'Edit'
    fill_in 'tags', with: 'super cool'
    click_on 'Save Changes'
    expect(page).to have_no_css '.asset-editor'
    expect(asset.reload.tags).to eq('super cool')
  end
end

