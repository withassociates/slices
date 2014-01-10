require 'spec_helper'

describe Page, "#update_attributes" do

  def update_page_attributes_with(page, options = {})
    options.reverse_merge!({
      'name'        => 'Updated parent',
      'permalink'   => 'parent',
      'active'      => 1,
      'show_in_nav' => 0,
      'layout'      => 'layout_three',
      'meta_description' => 'This is an important page',
      'title'       => 'Title',
    })
    page.update_attributes(options)
  end

  before do
    StandardTree.build_complex
  end

  let :home do
    Page.home
  end

  let :page do
    Page.find_by_path('/parent')
  end

  context "When changing a permalink" do
    before { update_page_attributes_with(page, 'permalink' => 'new-parent') }

    it "updates the path" do
      page.path.should eq '/new-parent'
      '/new-parent'.should be_findable
    end

    it "updates it's descendents paths" do
      '/new-parent/child'.should be_findable
      '/new-parent/child/grand-child'.should be_findable
    end
  end

  context "When updating with a blank path" do
    before do
      update_page_attributes_with(page, 'path' => '')
    end

    it "keeps the orginal path" do
      page.path.should eq '/parent'
      '/parent'.should be_findable
    end
  end

  context "When updating a child page" do
    let :child do
      Page.find_by_path('/parent/child')
    end

    before do
      update_page_attributes_with(child, 'permalink' => 'child')
    end

    it "keeps the orginal path" do
      child.path.should eq '/parent/child'
    end
  end

  context "When changing permalinks" do
    before do
      update_page_attributes_with(page, 'permalink' => 'Hello There')
    end

    it "updates the path" do
      page.path.should eq '/hello-there'
    end

    it "updates it's descendents paths" do
      '/hello-there/child'.should be_findable
      '/hello-there/child/grand-child'.should be_findable
    end

    it "updates the permalink" do
      page.permalink.should eq 'hello-there'
    end
  end

  context 'Updating home with attributes' do
    it "does not update the path" do
      update_page_attributes_with(home, 'name' => 'Hello There')
      home.path.should eq '/'
    end
  end
end

