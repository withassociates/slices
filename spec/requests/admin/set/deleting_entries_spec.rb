require 'spec_helper'

describe "A set with entries", type: :request, js: true do
  before do
    home, @page = StandardTree.build_minimal_with_slices
    sign_in_as_admin
    @set_page, articles = StandardTree.add_article_set(@page)
    @set_page.children.first.destroy

    visit admin_page_entries_path page_id: @set_page.id
  end

  it "displayes one article" do
    expect(page).to have_css 'tbody tr', count: 1
  end

  context "when an article is deleted" do
    before do
      @message = capture_js_confirm do
        js_click_on 'tbody tr:first-child td a.delete'
      end

      wait_for_ajax
    end

    it "is removed from the page" do
      expect(page).to have_css 'tbody tr', count: 0
      expect(page).to have_no_css 'tbody tr'
    end

    it "is really deleted on reload" do
      page.visit current_path
      expect(page).to have_no_css 'tbody tr'
    end

    it "asks me what i'm deleting" do
      @message.should == 'Are you sure?'
    end
  end
end
