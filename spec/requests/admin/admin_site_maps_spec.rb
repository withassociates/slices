require 'spec_helper'

describe "The site map", type: :request, js: true do

  before do
    @home, @page = StandardTree.build_minimal
    sign_in_as_admin
  end

  it "with virtual pages" do
    not_found, error = StandardTree.build_virtual

    visit '/admin/site_maps'

    expect(page).to have_css '#virtual-pages h2 a', text: error.name
    expect(page).to have_css '#virtual-pages h2 a', text: not_found.name

    expect(page).to have_no_css '#virtual-pages a.add-child'
  end

  it "shows pages of other types" do
    ExamplePage = Class.new(Page)
    ExamplePage.make(parent: @home, name: 'Example Page')

    visit '/admin/site_maps'

    expect(page).to have_css '#sitemap h2 a', text: 'Example Page'
  end

  it "doesn't show entries" do
    Article.make(parent: @home, name: 'Example Article')

    visit '/admin/site_maps'

    expect(page).not_to have_css '#sitemap h2 a', text: 'Example Article'
  end

  it "updates" do
    visit '/admin/site_maps'

    click_on 'Unlock structure?'
    click_on 'Save'

    expect(page).to have_content('Unlock structure?')
  end
end
