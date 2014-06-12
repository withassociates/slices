require 'spec_helper'

describe "The token field", type: :request, js: true do
  let! :home do
    StandardTree.build_home
  end

  let! :set_page do
    SetPage.make(
      parent:     home,
      name:       'Set Page',
      layout:     'default',
      slices:     [ArticleSetSlice.new(container:  'container_one')],
      set_slices: [PlaceholderSlice.new(container: 'container_one')]
    )
  end

  let! :entry do
    Article.make(
      parent: set_page,
      name:   'Entry',
    )
  end

  before do
    sign_in_as_admin
    visit admin_page_path entry
  end

  it "lets me enter freeform tokens" do
    begin
      fill_in('meta-categories', with: 'Art, Design, Branding')
    rescue Capybara::Poltergeist::ObsoleteNode
      # Acceptable error in this context
    end

    click_on_save_changes

    expect(page).to have_css '.token', text: 'Art'
    expect(page).to have_css '.token', text: 'Design'
    expect(page).to have_css '.token', text: 'Branding'
    expect(entry.reload.categories).to eq(%w[Art Design Branding])
  end

  it "lets me click an existing token", ci: false do
    within('#meta-tag') { click_on 'Will' }
    expect(page).to have_css('.token', text: 'Will')

    click_on_save_changes

    expect(page).to have_css('.token', text: 'Will')
    expect(entry.reload.tag).to eq('Will')
  end

end
