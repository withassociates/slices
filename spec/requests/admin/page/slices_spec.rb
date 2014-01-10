require 'spec_helper'

describe "Add/Edit/Delete slices on a page", js: true do

  let :new_slice_id do
    '#slice-__new__0'
  end

  before do
    home, @page = StandardTree.build_minimal_with_slices
    sign_in_as_admin
    visit "/admin/pages/#{@page.id}"
  end

  context "Adding" do
    before do
      select 'Title', from: 'add-slice-option'
    end

    it "1 slice" do
      click_on 'Save'

      within new_slice_id do
        page.should have_css ".field-with-errors"
        fill_in 'Title', with: 'New slice title'
      end

      click_on 'Save'

      page.should_not have_css '#container-slices .field-with-errors'
    end

    it "1 slice reloaded shouldn't duplicate itself" do
      within new_slice_id  do
        fill_in 'Title', with: 'New slice title'
      end
      click_on_save_changes

      page.should have_no_css('#container-slices .field-with-errors')

      visit admin_page_path @page
      click_on_save_changes

      page.should have_no_css(new_slice_id)
    end

  end
end
