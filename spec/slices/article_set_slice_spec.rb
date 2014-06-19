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
        expect(entries.size).to eq(5)
        expect(first.published_at).to be > last.published_at
      end
    end

    context "with no entries" do
      it "returns an empty array" do
        expect(set_slice.page_entries.size).to eq(0)
      end
    end
  end
end
