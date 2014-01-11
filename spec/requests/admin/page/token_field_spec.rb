require 'spec_helper'

describe "The token field", js: true do
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

    page.should have_css '.token', text: 'Art'
    page.should have_css '.token', text: 'Design'
    page.should have_css '.token', text: 'Branding'
    entry.reload.categories.should == %w[Art Design Branding]
  end

  it "lets me click an existing token", ci: false do
    within('#meta-author') { click_on 'Will' }
    page.should have_css '.token', text: 'Will'

    click_on_save_changes

    page.should have_css '.token', text: 'Will'
    entry.reload.author.should == 'Will'
  end

end
