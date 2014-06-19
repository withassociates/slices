require 'spec_helper'

describe Page do
  describe "#destroy" do

    context "with no children" do
      before do
        home, parent = StandardTree.build_minimal
        StandardTree.add_slices_beneath(home)

        parent.destroy
      end

      it "is not in home's children" do
        Page.home.children.entries.should eq []
      end

      it "deletes the parent page" do
        '/parent'.should_not be_findable
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
        Page.home.children.entries.should eq []
      end

      it "deletes the parent page" do
        '/parent'.should_not be_findable
      end

      it "deletes the child page" do
        '/parent/child'.should_not be_findable
      end

      it "deletes the grand child path" do
        '/parent/child/grand-child'.should_not be_findable
      end

    end
  end
end
