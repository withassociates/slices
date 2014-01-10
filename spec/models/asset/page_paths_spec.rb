require 'spec_helper'

describe Asset do

  let :asset do
    Asset.new
  end

  context "#update_page_cache" do
    context "when the asset is associated with pages" do
      before do
        page = double(:page, id: 1, name: '1', path: '/path')
        other_page = double(:page, id: 2, name: 'b', path: '/other-path')

        asset.stub(:page_ids).and_return [:id]
        asset.stub(:pages).and_return [page, other_page]
        asset.update_page_cache
      end

      it "sets page_cache" do
        asset.page_cache.should eq [
          {id: 1, name: '1', path:'/path'},
          {id: 2, name: 'b', path:'/other-path'}
        ]
      end

    end

    context "when the asset is not associated with pages" do
      before do
        asset.stub(:page_ids).and_return []
        asset.update_page_cache
      end

      it "sets page_cache to an empty array" do
        asset.page_cache.should eq []
      end

    end
  end

end

