require 'spec_helper'

describe "Slices with non-text inputs", type: :request, js: true do

  let :new_slice_id do
    '#slice-__new__0'
  end

  before do
    home, @page = StandardTree.build_minimal_with_slices
    sign_in_as_admin
    visit "/admin/pages/#{@page.id}"
  end

  context "Radio buttons" do
    before do
      select 'You Tube', from: 'add-slice-option'
    end

    it "persists the HD choice" do
      choose 'HD'
      expect(page).to have_checked_field 'HD'

      click_on 'Save'

      expect(page).to have_checked_field 'HD'
    end

  end
end
