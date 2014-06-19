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
    expect(page).to have_css 'title', text: 'Home'
  end

  it "renders the parent page" do
    visit '/parent'
    expect(page).to have_css 'title', text: 'Parent'
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
    expect(page).to have_css 'title', text: /not found/i
  end

  it "renders the 404 for an inactive page" do
    parent = Page.find_by_path('/parent')
    parent.update_attributes(active: false)

    visit '/parent'
    expect(page.status_code).to eq 404
    expect(page).to have_css 'title', text: /not found/i
  end

end
