require 'spec_helper'

describe Page, type: :model do

  describe "#update_last_changed_at" do
    it "updates the last changed when a page is saved" do
      page = Page.new(name: 'Page')
      expect(page).to receive(:update_last_changed_at)
      page.save
    end

    it "stores the last updated time in Rails.cache" do
      Rails.cache.write(Page::LAST_CHANGED_AT_CACHE_KEY, 'not yet changed')
      page = Page.new(name: 'Page')
      page.save
      expect(Rails.cache.read(Page::LAST_CHANGED_AT_CACHE_KEY)).to be_a(Integer)
    end
  end

  describe ".last_changed_at" do
    it "returns the value of the LAST_CHANGED_AT_CACHE_KEY" do
      Rails.cache.write(Page::LAST_CHANGED_AT_CACHE_KEY, 123)
      expect(Page.last_changed_at).to eq(123)
    end

    it "defaults to 0" do
      Rails.cache.delete(Page::LAST_CHANGED_AT_CACHE_KEY)
      expect(Page.last_changed_at).to eq(0)
    end
  end
end
