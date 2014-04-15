require 'spec_helper'

describe ArticleSetSlice do
  let :home do
    StandardTree.build_home
  end

  let :set_page do
    SetPage.make(
      parent: home,
      name:   'Blog',
      path:   '/blog',
      slices: [
        ArticleSetSlice.new(container: 'container_one', per_page: 5)
      ]
    )
  end

  let :set_slice do
    set_page.slices.first
  end

  describe "#page_entries" do
    context "with entries" do
      before do
        10.times do |n|
          Article.make(
            parent:       set_page,
            name:         "Article #{n}",
            permalink:    "article-#{n}",
            published_at: n.days.ago.at_beginning_of_day,
            active:       true,
            show_in_nav:  true
          )
        end
      end

      it "returns the latest 5 active entries" do
        entries = set_slice.page_entries
        first = entries.first
        last = entries.last
        entries.should have(5).items
        first.published_at.should > last.published_at
      end
    end

    context "with no entries" do
      it "returns an empty array" do
        set_slice.page_entries.should have(0).items
      end
    end
  end
end
