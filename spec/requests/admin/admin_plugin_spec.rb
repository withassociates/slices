require 'spec_helper'

describe "Extending a slice with javascript", type: :request, js: true do

  before do
    sign_in_as_admin
  end

  let! :my_page do
    home, my_page = StandardTree.build_minimal
    my_page
  end

  describe "the plugin in admin.js should run", js: true do

    context "when the slice is added" do
      before do
        visit admin_page_path my_page
        select "Lunch Choice", from: "add-slice-option"
      end

      it "comments on the user's choice" do
        select "Uludag", from: "Where are we going for lunch today?"
        expect(page).to have_css ".lunch-comment", text: "Good choice"
      end
    end

    context "on page load when the slice alread exists" do
      before do
        my_page.slices << LunchChoiceSlice.new(lunch: "uludag", container: "container_one")
        my_page.save!
        visit admin_page_path my_page
        select "Arthur’s", from: "Where are we going for lunch today?"
      end

      it "comments on the user's choice" do
        expect(page).to have_css ".lunch-comment", text: "Good choice"
      end

      it "saves the new choice" do
        click_on_save_changes
        expect(page).to have_select "Where are we going for lunch today?", selected: "Arthur’s"
      end
    end

  end

end
