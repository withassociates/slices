require 'spec_helper'

describe "An article set" do
  def visit_articles(params = {})
    if params.empty?
      visit "/parent/articles"
    else
      visit '/parent/articles?' + params.map { |k, v| "#{k}=#{v}" }.join('&')
    end
  end

  before do
    home, parent = StandardTree.build_minimal
    @set_page, articles = StandardTree.add_article_set(parent)
  end

  context "index page" do
    context "when no articles exist" do
      before do
        Article.destroy_all
      end

      it "renders succesfully" do
        visit_articles
        page.should have_content 'Articles'
      end
    end

    it "links to an article's own page" do
      visit_articles
      article = @set_page.children.first
      page.should have_link article.name, href: article.path
    end

    context "when lots of articles exist" do
      before do
        @article_set = @set_page.set_slice(:article)
        while Article.count <= @article_set.per_page + 1
          StandardTree.add_article(@set_page)
        end
      end

      it "limits the number of articles shown" do
        visit_articles
        page.should have_css "ul.entries li", count: @article_set.per_page
      end

      it "shows the correct page of articles" do
        visit_articles(page: 2)
        on_page_2 = Article.count - @article_set.per_page
        page.should have_css "ul.entries li", count: on_page_2
      end

      it "shows the pagination links" do
        visit_articles
        page.should have_link '2', href: @set_page.path + '?page=2'
      end
    end
  end

  context "an article page" do
    before do
      @article = Article.published.first
      @article.update_attributes(layout: 'layout_two')
    end

    it "renders the date published" do
      visit @article.path
      page.should have_css 'div.published_at', text: @article.published_at.to_s(:day_month_year)
    end

    it "renders shared content" do
      visit @article.path

      page.should have_css '.layout_two .container_one p:first-child', text: /appear above/
      page.should have_css '.layout_two .container_one p:first-child + h1', text: /Article/
      page.should have_css '.layout_two .container_one p:last-child', text: /appear below/
    end

    context "with shared content in multiple containers" do
      before do
        @set_page.set_slices << TextileSlice.new(textile: 'aside', container: 'container_two')
        @set_page.set_slices << PlaceholderSlice.new(container: 'container_two')
        @set_page.set_slices << PreparedSlice.new(container: 'container_two')
        @set_page.save!
        @article.slices << TextileSlice.new(textile: 'key points', container: 'container_two')
        @article.slices << PreparedSlice.new(container: 'container_two')
        @article.save!
      end

      it "renders shared content in a given container" do
        visit @article.path

        page.should have_css '.container_one p:nth-child(1)', text: /appear above/
        page.should have_css '.container_two p:nth-child(1)', text: 'aside'
        page.should have_css '.container_two p:nth-child(2)', text: 'key points'
        page.should have_css '.container_two p:nth-child(3)', text: 'prepared'
      end
    end

  end
end
