
# -*- encoding: utf-8 -*-
require 'spec_helper'

describe "Viewing the sets entries page", type: :request, js: true do

  context "with lots of articles" do
    before do
      home, @page = StandardTree.build_minimal_with_slices
      sign_in_as_admin
      @set_page, articles = StandardTree.add_article_set(@page)
      # Define predictable ordering
      @set_page.set_slice('Article').update_attributes(
        sort_field: 'name',
        sort_direction: 'asc'
      )
      51.times { StandardTree.add_article(@set_page) }
      visit admin_page_entries_path page_id: @set_page.id
    end

    let :articles do
      Article.asc(:name)
    end

    it "displays 50 articles" do
      expect(page).to have_css 'tbody tr', count: 50
    end

    it "has links to edit an entry" do
      article = articles.second

      expect(page).to have_css 'td a', text: article.name
      expect(page).to have_link article.name, href: admin_page_path(article.id)
    end

    context "viewing the second page" do
      before do
        js_click_on '#pagination li:last-child a'
      end

      it "displays 3 articles" do
        expect(page).to have_css 'tbody tr', count: 3
      end

    end
  end

  context "with no articles" do
    before do
      home, @page = StandardTree.build_minimal_with_slices
      sign_in_as_admin
      @set_page, articles = StandardTree.add_article_set(@page)
      @set_page.children.map &:destroy

      visit admin_page_entries_path page_id: @set_page.id
    end

    it "displays no articles" do
      expect(page).to have_no_css 'tbody tr'
    end

  end
end
