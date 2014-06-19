require 'spec_helper'

describe "GET to pages#show.hbs" do

  include_context "signed in as admin"

  before do
    home, @page = StandardTree.build_minimal
  end

  it "renders slice templates" do
    get admin_page_path(@page, format: :hbs),
      slice: 'lunch_choice',
      template: 'lunch_choice'

    expect(response.body).to include '<span class="lunch-comment" />'
  end

  it "renders page templates" do
    get admin_page_path(@page, format: :hbs),
      template: 'page_main'

    expect(response.body).to include '<p>hello</p>'
  end
end

