require 'spec_helper'

describe SetPage, type: :model do
  context "When a page has sets" do
    let :set_page do
      home, parent = StandardTree.build_minimal
      set_page, articles = StandardTree.add_article_set(home)
      set_page
    end

    it "they should_eventually be available" do
      expect(set_page.sets.first).to eq set_page.slices.first
    end

    it "be findable by type" do
      expect(set_page.set_slice(:article)).to eq set_page.sets.first
    end
  end

  context "When a page has children of different types" do
    before do
      home, parent = StandardTree.build_minimal
      @set_page, @articles = StandardTree.add_article_set(home)
      Page.make(parent: @set_page, permalink: 'a-page', name: 'A page')
    end

    it "be able to return children by type" do
      expect(@set_page.entries(:article)).to eq @articles
    end

    it "return list of available entry types" do
      expect(@set_page.entry_types).to include :article
    end
  end
end

