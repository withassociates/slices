require 'spec_helper'

describe "Assigning `:primary => true` on a container", type: :request, js: true do
  it "activates that container in the editor" do
    home = StandardTree.build_home
    home.update_attributes layout: 'layout_with_container_options'
    sign_in_as_admin
    visit admin_page_path home
    expect(page).to have_css '#container-tab-controls .active', text: 'Container Two'
  end
end