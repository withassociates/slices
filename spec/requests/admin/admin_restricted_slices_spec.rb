require 'spec_helper'

describe "Restricted slice", js: true do

  let! :my_page do
    home, my_page = StandardTree.build_minimal_with_slices
    my_page.slices << slice
    my_page.save!
    my_page
  end

  let :slice do
    PlaceholderSlice.new container: "container_one"
  end

  context "as a regular admin" do
    before do
      sign_in_as_admin
      visit admin_page_path my_page
    end

    it "is not addable" do
      page.should have_no_css 'option', text: 'Placeholder'
    end

    it "is not deletable" do
      page.should have_no_css "#slice-#{slice.id} .delete"
    end
  end

  context "as a super admin" do
    before do
      sign_in_as_super
      visit admin_page_path my_page
    end

    it "is addable" do
      page.should have_css 'option', text: 'Placeholder'
    end

    it "is deletable" do
      page.should have_css "#slice-#{slice.id} .delete"
    end
  end

end

