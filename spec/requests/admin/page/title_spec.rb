require 'spec_helper'

describe "The page editor title", type: :request, js: true do
  let! :home do
    StandardTree.build_home
  end

  before do
    sign_in_as_admin
    visit admin_page_path home
  end

  it "Uses the page name as the Title" do
    expect(page).to have_selector('title', content: 'Home')
  end

end
