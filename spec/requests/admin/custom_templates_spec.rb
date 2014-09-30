require 'spec_helper'

describe "Using custom template partials", type: :request do
  before do
    StandardTree.build_minimal
    @page_actions_template = Slices::Config.page_actions_template
    @page_fields_template = Slices::Config.page_fields_template
    Slices::Config.page_actions_template = 'custom/page_actions'
    Slices::Config.page_fields_template = 'custom/page_fields'
    sign_in_as_admin
  end

  after do
    Slices::Config.page_actions_template = @page_actions_template
    Slices::Config.page_fields_template = @page_fields_template
  end

  it "renders the configured page actions template" do
    expect(page).to have_link 'Add Project'
  end

  it "renders the configured page fields template" do
    visit new_admin_page_path
    expect(page).to have_field 'Title'
  end
end
