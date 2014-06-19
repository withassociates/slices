require 'spec_helper'

describe "Scrolling to the edge of the page", type: :request, js: true do

  before do
    100.times { Asset.create! file: file_fixture('document.zip') }
    sign_in_as_admin
    visit admin_assets_path
    expect(page).to have_css ".asset-library-item"
    page.execute_script %{$('.library-container').scrollTop(5000)}
  end

  it "loads an additional page of assets" do
    expect(page).to have_css ".asset-library-item", count: 100
  end

end

