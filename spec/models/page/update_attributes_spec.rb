require 'spec_helper'

describe Page, type: :model do
  describe "#update_attributes" do

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
        expect(page.path).to eq '/new-parent'
        expect('/new-parent').to be_findable
      end

      it "updates it's descendents paths" do
        expect('/new-parent/child').to be_findable
        expect('/new-parent/child/grand-child').to be_findable
      end
    end

    context "When updating with a blank path" do
      before do
        update_page_attributes_with(page, 'path' => '')
      end

      it "keeps the orginal path" do
        expect(page.path).to eq '/parent'
        expect('/parent').to be_findable
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
        expect(child.path).to eq '/parent/child'
      end
    end

    context "When changing permalinks" do
      before do
        update_page_attributes_with(page, 'permalink' => 'Hello There')
      end

      it "updates the path" do
        expect(page.path).to eq '/hello-there'
      end

      it "updates it's descendents paths" do
        expect('/hello-there/child').to be_findable
        expect('/hello-there/child/grand-child').to be_findable
      end

      it "updates the permalink" do
        expect(page.permalink).to eq 'hello-there'
      end
    end

    context 'Updating home with attributes' do
      it "does not update the path" do
        update_page_attributes_with(home, 'name' => 'Hello There')
        expect(home.path).to eq '/'
      end
    end
  end
end
