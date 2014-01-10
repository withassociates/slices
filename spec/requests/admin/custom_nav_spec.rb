require 'spec_helper'

describe "Using custom navbar partials" do
  before do
    StandardTree.build_home
    sign_in_as_admin
  end

  it "renders _custom_navigation" do
    page.should have_link 'Source'
  end

  it "renders _custom_links" do
    page.should have_link 'Suggestion Box'
  end
end
