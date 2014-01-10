require 'spec_helper'

describe "'Edit in CMS' button" do

  before do
    StandardTree.build_minimal
  end

  context "when not logged in" do
    it "is not shown" do
      visit '/'
      page.should have_no_css '#edit_in_cms'
    end
  end

  context "when logged in" do
    before do
      sign_in_as_admin
      Page.home.update_attributes(layout: 'default')
      visit '/'
    end

    it "is shown" do
      page.should have_css '#edit_in_cms'
    end

    it "is a link to the CMS" do
      page.should have_link 'Edit Page in CMS', href: "/admin/pages/#{Page.home.id}"
    end
  end

end
