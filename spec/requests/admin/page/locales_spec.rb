require 'spec_helper'

describe "locales", type: :request do
  before do
    home, @page = StandardTree.build_minimal_with_slices
    sign_in_as_admin
    visit "/admin/pages/#{@page.id}?locale=en"
  end

  it "shows links for other available locales" do
    expect(page).to have_link "de", href: admin_page_path(@page, locale: :de)
  end

  it "uses locale translation if present" do
    expect(page).to have_css '.toolbar.translations li', text: 'English'
  end

  it "uses locale if translation not present" do
    expect(page).to have_css '.toolbar.translations li', text: 'de'
  end
end
