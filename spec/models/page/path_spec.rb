require 'spec_helper'

describe Page, "setting the path" do
  before do
    home, page = StandardTree.build_minimal
    StandardTree.add_complex(home, page)
    @page_id = page.id.to_s
  end

  it "creates a unique permalink if permalink already exists" do
    new_page = Page.make(parent_id: @page_id, name: 'Child')
    new_page.path.should eq '/parent/child-1'
  end

  it "creates a unique permalink if multiple parmalinks already exists" do
    first_page = Page.make(parent_id: @page_id, name: 'Child')
    second_page = Page.make(parent_id: @page_id, name: 'Child')
    first_page.path.should eq '/parent/child-1'
    second_page.path.should eq '/parent/child-2'
  end

  it "uniquifies a permalink for a page on save" do
    new_parent = Page.make(parent_id: @page_id, name: 'New Child')
    new_parent.update_attributes(path: '/parent/child')

    new_parent.path.should eq '/parent/child-1'
  end

  it "does not uniquify peralinks unless nescessary" do
    first_page = Page.make(parent_id: @page_id, name: 'About-Me')
    second_page = Page.make(parent_id: @page_id, name: 'About-You')
    new_page = Page.make(parent_id: @page_id, name: 'About')

    new_page.path.should eq '/parent/about'
  end

  it "has a permalink if path is nil" do
    page = Page.new(name: 'page')

    page.permalink.should eq 'page'
  end
end

