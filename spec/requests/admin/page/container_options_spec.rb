require 'spec_helper'

describe "A container with options", js: true do
  before do
    home = StandardTree.build_home
    home.update_attributes layout: 'layout_with_container_options'
    sign_in_as_admin
    visit admin_page_path home
  end

  let :slice_picker do
    page.find('#add-slice-option')
  end

  it "excludes slices in the `except` option" do
    click_on 'Container Two'

    slice_picker.should_not have_content 'Lunch Choice'
  end

  it "only includes slices in the `only` option" do
    click_on 'Container One'

    slice_picker.should have_content 'Title'
    slice_picker.should have_content 'You Tube'
    slice_picker.should_not have_content 'Lunch Choice'
  end

  it "won't move slice into a container that doesn't allow it" do
    click_on 'Container Two'
    select 'Textile', from: 'add-slice-option'

    page.should_not have_css '.container-select'
  end

end