# -*- encoding: utf-8 -*-
require 'spec_helper'

describe "Clicking 'View page on site' after changing the permalink", type: :request, js: true do
  it "takes me to the right page" do
    home, parent = StandardTree.build_minimal

    example_page = Page.make(
      parent: home,
      name:   'Example',
      path:   '/example',
      layout: 'default',
      active: true
    )

    sign_in_as_admin
    visit admin_page_path example_page
    click_on 'advanced options…'
    fill_in 'Permalink', with: 'por-ejemplo'
    click_on 'Save changes'

    expect(page).to have_link 'View page on site', href: '/por-ejemplo'
  end
end
