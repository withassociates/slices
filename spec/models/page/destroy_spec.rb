require 'spec_helper'

describe Page, type: :model do
  describe "#destroy" do

    context "with no children" do
      before do
        home, parent = StandardTree.build_minimal
        StandardTree.add_slices_beneath(home)

        parent.destroy
      end

      it "is not in home's children" do
        expect(Page.home.children.entries).to eq []
      end

      it "deletes the parent page" do
        expect('/parent').not_to be_findable
      end

    end

    context "with children" do
      before do
        home, parent = StandardTree.build_minimal
        child = Page.make(parent: parent, name: 'Child')
        grand_child = Page.make(parent: child, name: 'Grand child')

        parent.destroy
      end

      it "is not in home's children" do
        expect(Page.home.children.entries).to eq []
      end

      it "deletes the parent page" do
        expect('/parent').not_to be_findable
      end

      it "deletes the child page" do
        expect('/parent/child').not_to be_findable
      end

      it "deletes the grand child path" do
        expect('/parent/child/grand-child').not_to be_findable
      end

    end
  end
end
