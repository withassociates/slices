require 'spec_helper'

describe "Asset deletion" do
  class MyPage < Page
    include Slices::HasAttachments
    has_attachments :images
  end

  class MySlice < Slice
    include Slices::HasAttachments
    has_attachments :images
  end

  let! :asset do
    Asset.create!(file: file_fixture('pepper-pot.jpg'))
  end

  let! :page_1 do
    MyPage.create!(
      name: 'Test page with its own attachments',
      images: [{ asset_id: asset.id }],
      slices: [MySlice.new(images: [{ asset_id: asset.id }])]
    )
  end

  let! :page_2 do
    page_2 = Page.create!(
      name: 'Test page with only slice attachments',
      slices: [MySlice.new(images: [{ asset_id: asset.id }])]
    )
  end

  it "removes Assets from Pages and Slices with #soft_destroy" do
    asset.reload.soft_destroy!

    page_1.reload
    page_2.reload

    expect(page_1.images).to be_empty
    expect(page_1.slices.first.images).to be_empty
    expect(page_2.slices.first.images).to be_empty
  end

  it "removes Assets from Pages and Slices with #destroy" do
    asset.reload.destroy

    page_1.reload
    page_2.reload

    expect(page_1.images).to be_empty
    expect(page_1.slices.first.images).to be_empty
    expect(page_2.slices.first.images).to be_empty
  end
end
