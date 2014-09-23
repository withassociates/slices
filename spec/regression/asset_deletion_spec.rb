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

  it "removes Assets from Pages and Slices with #soft_destroy" do
    asset = Asset.create!(file: file_fixture('pepper-pot.jpg'))

    page_1 = MyPage.create!(
      name: 'Test page with its own attachments',
      images: [{ asset_id: asset.id }],
      slices: [MySlice.new(images: [{ asset_id: asset.id }])]
    )

    page_2 = Page.create!(
      name: 'Test page with only slice attachments',
      slices: [MySlice.new(images: [{ asset_id: asset.id }])]
    )

    asset.reload.soft_destroy!

    page_1.reload
    page_2.reload

    page_1.images.should == []
    page_1.slices.first.images.should == []
    page_2.slices.first.images.should == []
  end

  it "removes Assets from Pages and Slices with #destroy" do
    asset = Asset.create!(file: file_fixture('pepper-pot.jpg'))

    page_1 = MyPage.create!(
      name: 'Test page with its own attachments',
      images: [{ asset_id: asset.id }],
      slices: [MySlice.new(images: [{ asset_id: asset.id }])]
    )

    page_2 = Page.create!(
      name: 'Test page with only slice attachments',
      slices: [MySlice.new(images: [{ asset_id: asset.id }])]
    )

    asset.reload.destroy

    page_1.reload
    page_2.reload

    page_1.images.should == []
    page_1.slices.first.images.should == []
    page_2.slices.first.images.should == []
  end
end
