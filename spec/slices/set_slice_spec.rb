require 'spec_helper'

describe SetSlice do

  class DummyPageSetSlice < SetSlice
  end

  class DummyPage < Page
  end

  context "Set with entries" do
    let :set_page do
      home, parent = StandardTree.build_minimal
      set_page, articles = StandardTree.add_article_set(parent)
      set_page.slices << DummyPageSetSlice.new(container: 'container_one')
      set_page.save!
      DummyPage.make(
        parent: set_page,
        permalink: 'dummy',
        name: 'Dummy'
      )
      set_page
    end

    let :article_slice do
      set_page.set_slice(:article)
    end

    it "is able to iterate over it's own entries" do
      article_slice.entries.map(&:class).uniq.should include Article
    end

    it "return a limited number of entries per page" do
      while article_slice.entries.length <= article_slice.per_page + 1
        StandardTree.add_article(set_page)
      end
      article_slice.page_entries.length.should eq article_slice.per_page
    end

  end
end
