require 'spec_helper'

describe "The radio field", type: :request, js: true do
  let! :home do
    StandardTree.build_home
  end

  let! :slice do
    home.slices << MultipleChoiceSlice.new(container: 'container_one')
    home.slices.last
  end

  before do
    sign_in_as_admin
    visit admin_page_path home
  end

  it "lets me choose an option" do
    selector = '.radio-field input[type="radio"]'

    first(selector).click
    click_on_save_changes

    expect(page).to have_css(selector + '[value="A"]:checked')
    expect(slice.reload.answer).to eq('A')
  end
end
