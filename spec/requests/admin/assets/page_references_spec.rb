require 'spec_helper'

describe "Viewing page_paths on an asset", type: :request, js: true do

  let :slide do
    { asset_id: asset.id }
  end

  let! :asset do
    Asset.make file: file_fixture
  end

  before do
    parent
    sign_in_as_admin
    visit admin_assets_path
    js_click_on '.asset-library-item:first-child a[data-action="edit"]'
  end

  context "when an asset is used" do
    let! :parent do
      StandardTree.build_minimal.last.tap do |parent|
        parent.slices << SlideshowSlice.new(slides: [slide])
        parent.save
      end
    end

    it "has a link to edit the associated page" do
      path = "/admin/pages/" + parent.id.to_s
      expect(page).to have_css 'a[href="' + path + '"]', text: 'Parent'
    end
  end

  context "when the asset is unused" do
    let! :parent do
      StandardTree.build_minimal.last
    end

    it "has no links to related pages" do
      expect(page).to have_no_css 'div.pages h3'
    end
  end

end

