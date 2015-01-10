require 'spec_helper'

describe "A simple site", type: :request do
  extend ErrorHandlingMacros
  enable_production_error_handling

  before do
    home, parent = StandardTree.build_minimal

    home.update_attributes(layout: 'layout_one')
    parent.update_attributes(layout: 'layout_two')
    StandardTree.build_virtual
  end

  it "renders the home page" do
    visit '/'
    expect(page).to have_title 'Home'
  end

  it "renders the parent page" do
    visit '/parent'
    expect(page).to have_title 'Parent'
  end

  it "renders homepage with layout one" do
    visit '/'
    expect(page).to have_css 'body.layout_one', count: 1
  end

  it "renders the parent page with layout two" do
    visit '/parent'
    expect(page).to have_css 'body.layout_two', count: 1
  end

  it "renders the 404 for a missing page" do
    visit '/no-such-page'

    expect(page.status_code).to eq 404
    expect(page).to have_title /not found/i
  end

  it "renders the 404 for an inactive page" do
    parent = Page.find_by_path('/parent')
    parent.update_attributes(active: false)

    visit '/parent'
    expect(page.status_code).to eq 404
    expect(page).to have_title /not found/i
  end

  describe "that has been translated", i18n: true do
    before do
      parent = Page.find_by_path('/parent')
      allow(Slices::Translations).to receive(:all).and_return(
        en: 'English',
        de: 'German'
      )
    end

    it "redirects requests to the root page to home page for default locale" do
      visit '/'
      expect(page).to have_title 'Home'
      expect(current_path).to eq '/en'
    end

    it "serves the home page from URL that just contains the locale" do
      %w(de en).each do |locale|
        visit "/#{locale}"
        expect(page.status_code).to eq 200
      end
    end

    it "serves the page from a URL prefixed with the locale" do
      %w(de en).each do |locale|
        visit "/#{locale}/parent"
        expect(page.status_code).to eq 200
      end
    end

    it "renders 404 for URLs that don't include the locale prefix" do
      expect { visit '/parent' }.to raise_error(ActionController::RoutingError)
    end
  end
end
