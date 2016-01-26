require 'spec_helper'

describe "A page with extra templates", type: :request, js: true do
  before do
    home = StandardTree.build_home
    page = Project.make name: 'Example', parent: home
    sign_in_as_admin
    visit admin_page_path(page)
  end

  it "shows fields from all templates" do
    expect(page).to have_css 'label', text: 'Description'
    expect(page).to have_css 'label', text: 'Client'
  end
end
