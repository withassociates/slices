require 'spec_helper'

describe "DELETE to pages#destroy" do

  include_context "signed in as admin"

  before do
    home, page = StandardTree.build_minimal_with_slices
    delete admin_page_path(page.to_param, format: :json)
  end

  it "responds with deleted (no content)" do
    response.code.should eq '204'
  end

end

