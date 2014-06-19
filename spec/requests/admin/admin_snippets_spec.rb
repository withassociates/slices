require 'spec_helper'

describe "Admin Snippets", %q{
  In order to keep the site up to date
  As an admin user
  I want to edit snippets
}, type: :request, js: true do

  before do
    StandardTree.build_minimal
    @hello = Snippet.create(key: 'en.hello', value: 'Hello')
    @bye = Snippet.create(key: 'en.bye', value: 'Bye')
    sign_in_as_admin
    click_on 'Snippets'
  end

  it "Viewing snippets" do
    expect(page).to have_css('tbody tr', count: 2)
  end

  it "Editing a snippet" do
    within('tbody tr:first-child') do
      click_on 'Edit'
    end
    fill_in 'Value', with: 'Courage Wolf'
    click_button 'Save'

    expect(page).to have_css('tbody tr', count: 2)
    expect(page).to have_css('tbody tr', text: 'Courage Wolf')
  end

end

