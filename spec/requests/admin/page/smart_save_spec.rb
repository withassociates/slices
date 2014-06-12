require 'spec_helper'

describe "The 'Save changes' button", type: :request, js: true do
  subject do
    find '#save-changes', visible: false
  end

  before do
    home, parent = StandardTree.build_minimal
    set_page, articles = StandardTree.add_article_set home
    article = articles.first
    article.slices << TextileSlice.new(container: 'container_one', textile: 'Testing')
    article.save!
    sign_in_as_admin
    visit admin_page_path article
  end

  context "before changes have been made" do
    it "is disabled" do
      is_expected.to be_disabled
    end
  end

  context "after a field is edited" do
    before do
      fill_in 'Page Name', with: 'Lucy in the Sky with Diamonds'
    end

    it "is enabled" do
      is_expected.not_to be_disabled
    end
  end

  context "when slices are re-ordered" do
    before do
      page.execute_script %{$('.slice').closest('ul').trigger('sortstop')}
    end

    it "is enabled" do
      is_expected.not_to be_disabled
    end
  end

  context "when a slice is added" do
    before do
      select 'Lunch Choice', from: 'add-slice-option'
    end

    it "is enabled" do
      is_expected.not_to be_disabled
    end
  end

  context "when a slice is removed" do
    before do
      find('.slice:first-child .delete').click
    end

    it "is enabled" do
      is_expected.not_to be_disabled
    end
  end

  context "when a slice is moved to another container" do
    before do
      within 'li.slice:first-child' do
        select 'Container Two'
      end
    end

    it "is enabled" do
      is_expected.not_to be_disabled
    end
  end

  context "when using a tag field" do
    it "is enabled" do
      within '#meta-tag' do
        click_on 'Will'
      end
      is_expected.to be_enabled
    end
  end

  context "after saving" do
    before do
      find('.slice:first-child .delete').click
      click_on_save_changes
    end

    it "is disabled" do
      is_expected.to be_disabled
    end

    it "re-enables when a field is changed" do
      fill_in 'Page Name', with: 'Helter Skelter'
      is_expected.not_to be_disabled
    end
  end

end
