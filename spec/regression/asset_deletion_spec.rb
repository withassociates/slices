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

  let! :asset_1 do
    Asset.create!(file: file_fixture('pepper-pot.jpg'))
  end

  let! :asset_2 do
    Asset.create!(file: file_fixture('lady bird.jpg'))
  end

  let! :page_1 do
    MyPage.create!(
      name: 'Test page with its own attachments',
      images: [{ asset_id: asset_1.id }],
      slices: [MySlice.new(images: [{ asset_id: asset_1.id }, { asset_id: asset_2.id }])]
    )
  end

  let! :page_2 do
    page_2 = Page.create!(
      name: 'Test page with only slice attachments',
      slices: [MySlice.new(images: [{ asset_id: asset_1.id }])]
    )
  end

  it "removes Assets from Pages and Slices with #destroy" do
    asset_1.reload.destroy

    page_1.reload
    page_2.reload

    expect(page_1.images).to be_empty
    expect(page_1.slices.first.images.length).to eq 1
    expect(page_2.slices.first.images).to be_empty
  end

end
