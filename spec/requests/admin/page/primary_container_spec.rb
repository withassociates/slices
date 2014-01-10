require 'spec_helper'

describe "Assigning `:primary => true` on a container", js: true do
  it "activates that container in the editor" do
    home = StandardTree.build_home
    home.update_attributes layout: 'layout_with_container_options'
    sign_in_as_admin
    visit admin_page_path home
    page.should have_css '#container-tab-controls .active', text: 'Container Two'
  end
end