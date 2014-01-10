require 'spec_helper'

describe "The site map", js: true do

  before do
    home, @page = StandardTree.build_minimal
    sign_in_as_admin
  end

  it "with virtual pages" do
    not_found, error = StandardTree.build_virtual

    visit '/admin/site_maps'

    page.should have_css '#virtual-pages h2 a', text: error.name
    page.should have_css '#virtual-pages h2 a', text: not_found.name

    page.should have_no_css '#virtual-pages a.add-child'
  end

end
