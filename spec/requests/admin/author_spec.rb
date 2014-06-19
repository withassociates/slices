require 'spec_helper'

describe "History", type: :request, js: true do
  let! :admin do
    sign_in_as_admin
  end

  before do
    StandardTree.build_minimal
    visit new_admin_page_path(parent_id: Page.home.id)
    fill_in 'Name', with: 'Foo Bar'
    click_on 'Create Page'
    click_on 'advanced options'
  end

  it "records the author on creation" do
    expect(page).to have_content "Created by #{admin.name}"
  end
end
