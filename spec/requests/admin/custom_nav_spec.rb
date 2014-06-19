require 'spec_helper'

describe "Using custom navbar partials", type: :request do
  before do
    StandardTree.build_home
    sign_in_as_admin
  end

  it "renders _custom_navigation" do
    expect(page).to have_link 'Source'
  end

  it "renders _custom_links" do
    expect(page).to have_link 'Suggestion Box'
  end
end
