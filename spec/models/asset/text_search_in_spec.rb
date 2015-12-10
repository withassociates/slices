require 'spec_helper'

describe Asset, type: :model do

  context "searching on :name" do
    before do
      Asset.make(name: 'Otters and DolPHINS', file: file_fixture)
      Asset.make(name: 'Capybaras and Otters', file: file_fixture('pepper-pot.jpg'))
      Asset.make(name: 'dolphins & cuttlefish', file: file_fixture('test.pdf'))
    end

    it 'returns a Mongoid::Criteria object' do
      expect(Asset.basic_text_search('dolphins')).to be_a(Mongoid::Criteria)
    end

    it 'returns two results when searching for dolphins' do
      expect(Asset.basic_text_search('dolphins').count).to eq 2
    end

    it 'return two results when searching for otters' do
      expect(Asset.basic_text_search('otters').count).to eq 2
    end

    it 'return one result when searching for cuttlefish' do
      expect(Asset.basic_text_search('cuttlefish').count).to eq 1
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
      allow(asset).to receive_messages(update_page_cache: true)
      asset.page_cache = page_cache
      asset.save
    end

    it "stores pages_paths" do
      # Make sure the page cache isn't overridden
      expect(asset.page_cache).to eq page_cache
    end

    it "stores pages_paths in _keywords" do
      expect(asset.reload._keywords).to include '/animals'
    end

    it "return one result when searching for animals" do
      expect(Asset.basic_text_search('animals').count).to eq 1
    end

    it "return one result when searching for creatures" do
      expect(Asset.basic_text_search('creatures').count).to eq 1
    end
  end
end

