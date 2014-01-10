require 'spec_helper'

describe Asset do

  context "searching on :name" do
    before do
      Asset.make(name: 'Otters and DolPHINS', file: file_fixture)
      Asset.make(name: 'Capybaras and Otters', file: file_fixture('pepper-pot.jpg'))
      Asset.make(name: 'dolphins & cuttlefish', file: file_fixture('test.pdf'))
    end

    it 'returns two results when searching for dolphins' do
      Asset.text_search('dolphins').count.should eq 2
    end

    it 'return two results when searching for otters' do
      Asset.text_search('otters').count.should eq 2
    end

    it 'return one result when searching for cuttlefish' do
      Asset.text_search('cuttlefish').count.should eq 1
    end
  end

  context "searching on :page_cache" do
    let :asset do
      Asset.make(name: 'Otters', file: file_fixture)
    end

    let :page_cache do
      [{'id' => 1, 'name' => 'creatures', 'path' => '/animals'}]
    end

    before do
      asset.stub(update_page_cache: true)
      asset.page_cache = page_cache
      asset.save
    end

    it "stores pages_paths" do
      # Make sure the page cache isn't overridden
      asset.page_cache.should eq page_cache
    end

    it "stores pages_paths in _keywords" do
      asset.reload._keywords.should include '/animals'
    end

    it "return one result when searching for animals" do
      Asset.text_search('animals').count.should eq 1
    end

    it "return one result when searching for creatures" do
      Asset.text_search('creatures').count.should eq 1
    end
  end
end

