require 'spec_helper'

describe Asset, type: :model do

  let :asset do
    Asset.new
  end

  context "#update_page_cache" do
    context "when the asset is associated with pages" do
      before do
        page = double(:page, id: 1, name: '1', path: '/path')
        other_page = double(:page, id: 2, name: 'b', path: '/other-path')
        pages = [page, other_page]

        allow(pages).to receive(:exists?)
        allow(asset).to receive(:page_ids).and_return [:id]
        allow(asset).to receive(:pages).and_return(pages)
        asset.update_page_cache
      end

      it "sets page_cache" do
        expect(asset.page_cache).to eq [
          {id: 1, name: '1', path:'/path'},
          {id: 2, name: 'b', path:'/other-path'}
        ]
      end

    end

    context "when the asset is not associated with pages" do
      before do
        allow(asset).to receive(:page_ids).and_return []
        asset.update_page_cache
      end

      it "sets page_cache to an empty array" do
        expect(asset.page_cache).to eq []
      end

    end
  end

end

