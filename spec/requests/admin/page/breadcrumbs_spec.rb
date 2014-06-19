require 'spec_helper'

describe "The page editor breadcrumb nav", type: :request, js: true do
  let! :home do
    StandardTree.build_home
  end

  let! :grandparent do
    Page.make parent: home, name: 'Grandparent', permalink: 'grandparent'
  end

  let! :parent do
    Page.make parent: grandparent, name: 'Parent', permalink: 'parent'
  end

  let! :child do
    Page.make parent: parent, name: 'Child', permalink: 'child'
  end

  let! :grandchild do
    Page.make parent: child, name: 'Grandchild', permalink: 'grandchild'
  end

  before do
    sign_in_as_admin
    visit admin_page_path child
  end

  it "links to all the appropriate pages" do
    expect(page).to have_link 'Home'
    expect(page).to have_link 'Grandparent'
    expect(page).to have_link 'Parent'
    expect(page).to have_link 'Child'

    expect(page).to have_select 'children', with_options: ['Grandchild']
  end

  it "updates when the page name changes" do
    fill_in 'Page Name', with: 'Foo Bar'
    click_on 'Save changes'

    expect(page).to have_link 'Foo Bar'
  end

  it "naviagtes to the child page when selected" do
    select 'Grandchild', from: 'children'
    expect(page).to have_field 'Page Name', with: 'Grandchild'
  end
end
