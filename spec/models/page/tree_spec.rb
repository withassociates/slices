require 'spec_helper'

describe Page do

  context "tree building" do

    before do
      home = Page.create(name: 'Home')
      parent = Page.create(name: 'Parent')

      parent.parent = home
      parent.save
      home.save

      @home = Page.find(home.id)
      @parent = Page.find(parent.id)
    end

    it "does not set page on home" do
      @home.parent.should be_nil
    end

    it "has @home as @parent.page" do
      @home.should eq @parent.parent
    end

    it "includes @parent in @home.children" do
      @home.children.entries.should include @parent
    end

  end

  context "tree navigating" do
    before do
      StandardTree.build_complex
    end

    let :home do
      Page.home
    end

    let :parent do
      Page.find_by_path('/parent')
    end

    let :child do
      Page.find_by_path('/parent/child')
    end

    let :sibling do
      Page.find_by_path('/parent/sibling')
    end

    let :youngest do
      Page.find_by_path('/parent/youngest')
    end

    context "the home page" do
      it "is home page" do
        home.should be_home
      end

      it "has no parent" do
        home.parent.should be_nil
      end

      it "has no any siblings" do
        home.siblings.should eq []
      end

      it "is not a first sibling" do
        home.should_not be_first_sibling
      end

      it "is not a last sibling" do
        home.should_not be_last_sibling
      end

      it "has parent as a child" do
        home.children.entries.should include parent
      end
    end

    context "the parent page" do
      it "is not the home page" do
        parent.should_not be_home
      end

      it "has a parent" do
        parent.parent.should eq Page.home
      end

      it "has children" do
        parent.children.entries.should eq [child, sibling, youngest]
      end
    end

    context "the child page (parent's first child)" do

      it "is the first sibling" do
        child.should be_first_sibling
      end

      it "is not the last s a next sibling" do
        child.should_not be_last_sibling
      end

      it "has no previous sibling" do
        child.previous_sibling.should be_nil
      end

      it "has sibling as the next sibling" do
        child.next_sibling.should eq sibling
      end

      it "has siblings" do
        child.siblings.entries.should eq [sibling, youngest]
      end
    end

    context "the sibling page (parent's middle child)" do

      it "is not the first sibling" do
        sibling.should_not be_first_sibling
      end

      it "is not the last sibling" do
        sibling.should_not be_last_sibling
      end

      it "has sibling as the previous sibling" do
        sibling.previous_sibling.should eq child
      end

      it "has youngest as the next sibling" do
        sibling.next_sibling.should eq youngest
      end

      it "has siblings" do
        sibling.siblings.entries.should eq [child, youngest]
      end
    end

    context "the youngest page (parent's youngest child)" do

      it "is not the first sibling" do
        youngest.should_not be_first_sibling
      end

      it "is the last sibling" do
        youngest.should be_last_sibling
      end

      it "has a previous sibling" do
        youngest.previous_sibling.should eq sibling
      end

      it "has no next sibling" do
        youngest.next_sibling.should be_nil
      end

      it "has siblings" do
        youngest.siblings.entries.should eq [child, sibling]
      end
    end
  end

end
