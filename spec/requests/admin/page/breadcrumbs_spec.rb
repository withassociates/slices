require 'spec_helper'

describe "The page editor breadcrumb nav", js: true do
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
    page.should have_link 'Home'
    page.should have_link 'Grandparent'
    page.should have_link 'Parent'
    page.should have_link 'Child'

    page.should have_select 'children', with_options: ['Grandchild']
  end

  it "updates when the page name changes" do
    fill_in 'Page Name', with: 'Foo Bar'
    click_on 'Save changes'

    page.should have_link 'Foo Bar'
  end

  it "naviagtes to the child page when selected" do
    select 'Grandchild', from: 'children'
    page.should have_field 'Page Name', with: 'Grandchild'
  end
end
