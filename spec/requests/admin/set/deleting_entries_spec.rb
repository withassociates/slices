require 'spec_helper'

describe "A set with entries", js: true do
  before do
    home, @page = StandardTree.build_minimal_with_slices
    sign_in_as_admin
    @set_page, articles = StandardTree.add_article_set(@page)
    @set_page.children.first.destroy

    visit admin_page_entries_path page_id: @set_page.id
  end

  it "displayes one article" do
    page.should have_css 'tbody tr', count: 1
  end

  context "when an article is deleted" do
    before do
      js_click_on 'tbody tr:first-child td a.delete'
    end

    it "is removed from the page" do
      page.should_not have_css 'tbody tr'
    end

    it "is really deleted on reload" do
      sleep 0.2
      page.visit current_path
      sleep 0.2
      page.should_not have_css 'tbody tr'
    end

  end
end
