require 'spec_helper'

describe "Asset Reference" do

  context "when an asset slice is added to /parent" do
    let! :asset do
      Asset.make file: file_fixture
    end

    let! :parent do
      StandardTree.build_minimal.last
    end

    let :slide do
      {
        asset_id: asset.id,
        caption: 'Hello World'
      }
    end

    before do
      parent.slices << SlideshowSlice.new(slides: [slide])
      parent.save
    end

    it "stores the page url in the asset page_cache" do
      asset.reload.page_cache.first.should include ({'path' => '/parent'})
    end

    it "stores the page id in the pages ids" do
      asset.reload.page_ids.should include parent.id
    end
  end

  context "when an asset slice is removed from /parent" do
    let! :asset do
      Asset.make file: file_fixture
    end

    let! :parent do
      StandardTree.build_minimal.last.tap do |parent|
        parent.slices << SlideshowSlice.new(slides: [slide])
        parent.save
      end
    end

    let :slide do
      {
        asset_id: asset.id,
        caption: 'Hello World'
      }
    end

    let :loaded_asset do
      asset.reload
    end

    context "adding" do
      it "(asset) adds the page url to the asset page_cache" do
        loaded_asset.page_cache.first.should include ({'path' => '/parent'})
      end

      it "(asset) has reference of page" do
        loaded_asset.page_ids.should eq [parent.id]
      end

      it "(page) has reference of asset" do
        parent.reload.asset_ids.should eq [asset.id]
      end

      it "(page) has referenced attachments" do
        parent.reload.attachment_asset_ids.should eq [asset.id]
      end

    end

    context "removed" do
      before do
        parent.slices.last.delete
        parent.save
      end

      it "removes the page url from the asset page_cache" do
        loaded_asset.page_cache.should eq []
      end

      it "(asset) has no reference of page" do
        loaded_asset.page_ids.should eq []
      end

      it "(page) has no reference of asset" do
        parent.reload.asset_ids.should eq []
      end

      it "(page) has no reference of attachments" do
        parent.reload.attachment_asset_ids.should eq []
      end
    end
  end

  context "when two assets slice are added to /parent" do
    let! :asset do
      Asset.make file: file_fixture
    end

    let! :parent do
      StandardTree.build_minimal.last.tap do |parent|
        parent.slices << SlideshowSlice.new(slides: [slide])
        parent.save
      end
    end

    let :slide do
      {
        asset_id: asset.id,
        caption: 'Hello World'
      }
    end

    before do
      parent.slices << SlideshowSlice.new(slides: [slide])
      parent.save
    end

    it "adds the page url to the asset page_cache" do
      asset.reload.page_cache.first.should include ({'path' => '/parent'})
    end
  end

  context "when a page is renamed" do
    let! :asset do
      Asset.make file: file_fixture
    end

    let! :parent do
      StandardTree.build_minimal.last.tap do |parent|
        parent.slices << SlideshowSlice.new(slides: [slide])
        parent.save
      end
    end

    let :slide do
      {
        asset_id: asset.id,
        caption: 'Hello World'
      }
    end

    before do
      parent.reload.update_attributes(permalink: 'new-parent')
    end

    it "updates the page url from the asset page_cache" do
      asset.reload.page_cache.first.should include ({'path' => '/new-parent'})
    end

    it "changes the path" do
      parent.reload.path.should eq '/new-parent'
    end
  end
end
