# -*- encoding: utf-8 -*-
require 'spec_helper'

def add_title_slice(text)
  select 'Title', from: 'add-slice-option'
  within("#container-container_one ul.slices-holder > li:last-child") do
    fill_in 'Title', with: text
  end
end

describe "Add/Edit/Delete slices on a page", js: true do
  before do
    home, @page = StandardTree.build_minimal_with_slices
    sign_in_as_admin
    @new_slice_id = '#slice-__new__0'
    visit "/admin/pages/#{@page.id}"
  end

  context "Adding" do
    before do
      select 'Title', from: 'add-slice-option'
    end

    it "1 slice" do
      click_on 'Save'

      within @new_slice_id do
        page.should have_css ".field-with-errors"
        fill_in 'Title', with: 'New slice title'
      end

      click_on 'Save'

      page.should_not have_css '#container-slices .field-with-errors'
    end

    it "1 slice reloaded shouldn't duplicate itself" do
      within(@new_slice_id) do
        fill_in 'Title', with: 'New slice title'
      end
      click_on_save_changes

      page.should have_no_css('#container-slices .field-with-errors')

      sleep 0.5
      visit "/admin/pages/#{@page.id}"
      click_on_save_changes

      page.should have_no_css(@new_slice_id)
    end

    it "three slices added in order should stay in that order when reloaded" do
      within(@new_slice_id) do
        fill_in 'Title', with: 'one'
      end
      add_title_slice('two')
      add_title_slice('three')
      add_title_slice('four')
      click_on_save_changes

      # binding.pry
      within('#container-container_one .slice:nth-child(2)') do
        find_field('Title').value.should == 'one'
      end
      within('#container-container_one .slice:nth-child(3)') do
        find_field('Title').value.should == 'two'
      end
      within('#container-container_one .slice:nth-child(4)') do
        find_field('Title').value.should == 'three'
      end
    end
  end

  context "Deleting" do
    it "1 slice is deleted" do
      click_on 'Delete'
      click_on_save_changes
      find(".slices-holder li").visible?.should be_false
    end
  end
end

describe 'Edit slices on all entries in a set', js: true do
  def set_entries_page
    "/admin/pages/#{@page.id}?entries=1"
  end

  before do
    home, parent = StandardTree.build_minimal
    sign_in_as_admin
    @page, articles = StandardTree.add_article_set(home)
    @new_slice_id = '#slice-__new__0'
    visit set_entries_page
  end

  context "Editing" do
    it "a textile slice" do
      first_slice_selector = 'ul.slices-holder li:first-child'
      new_copy = 'New copy for this slice'
      within(first_slice_selector) do
        fill_in 'textile', with: new_copy
      end

      click_on_save_changes
      visit set_entries_page
      sleep 0.2
      page.should have_css(first_slice_selector + ' textarea', text: new_copy)
    end
  end
end

describe 'Page data and meta-data', js: true do
  before do
    home, @page = StandardTree.build_minimal_with_slices
    sign_in_as_admin
    visit "/admin/pages/#{@page.id}"
  end

  it "Meta fields" do
    updated_parent = 'new-parent'
    updated_description = 'This page is very interesting'

    click_on "advanced options…"
    fill_in 'meta-permalink', with: updated_parent
    fill_in 'meta-meta_description', with: updated_description

    click_on 'Save'

    page.should have_field 'meta-permalink', text: updated_parent
    page.should have_field 'meta-meta_description', text: updated_description
  end
end

