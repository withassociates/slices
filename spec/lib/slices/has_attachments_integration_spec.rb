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
      expect(asset.reload.page_cache.first).to include ({'path' => '/parent'})
    end

    it "stores the page id in the pages ids" do
      expect(asset.reload.page_ids).to include parent.id
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
        expect(loaded_asset.page_cache.first).to include ({'path' => '/parent'})
      end

      it "(asset) has reference of page" do
        expect(loaded_asset.page_ids).to eq [parent.id]
      end

      it "(page) has reference of asset" do
        expect(parent.reload.asset_ids).to eq [asset.id]
      end

      it "(page) has referenced attachments" do
        expect(parent.reload.attachment_asset_ids).to eq [asset.id]
      end

    end

    context "removed" do
      before do
        parent.slices.last.delete
        parent.save
      end

      it "removes the page url from the asset page_cache" do
        expect(loaded_asset.page_cache).to eq []
      end

      it "(asset) has no reference of page" do
        expect(loaded_asset.page_ids).to eq []
      end

      it "(page) has no reference of asset" do
        expect(parent.reload.asset_ids).to eq []
      end

      it "(page) has no reference of attachments" do
        expect(parent.reload.attachment_asset_ids).to eq []
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
      expect(asset.reload.page_cache.first).to include ({'path' => '/parent'})
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
      expect(asset.reload.page_cache.first).to include ({'path' => '/new-parent'})
    end

    it "changes the path" do
      expect(parent.reload.path).to eq '/new-parent'
    end
  end
end
