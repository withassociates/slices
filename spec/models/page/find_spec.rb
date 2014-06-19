require 'spec_helper'

describe Page do
  describe ".find_by_path" do

    context "when pages exist" do

      before do
        @home, @parent = StandardTree.build_minimal
      end

      it "returns the home page" do
        Page.find_by_path('/').should eq @home
      end

      it "returns the parent page" do
        Page.find_by_path('/parent').should eq @parent
      end

      it "returns the child page" do
        child, grand_child = StandardTree.add_complex(@home, @parent)
        Page.find_by_path('/parent/child').should eq child
      end

      it "returns the grand child page" do
        child, grand_child = StandardTree.add_complex(@home, @parent)
        Page.find_by_path('/parent/child/grand-child').should eq grand_child
      end
    end

    context "when pages do not exist" do
      it "raises Page::NotFound" do
        lambda {
          Page.find_by_path('no-such-page')
        }.should raise_error Page::NotFound
      end
    end
  end

  describe ".find_by_id" do

    context "when pages exist" do
      before do
        @home, @parent = StandardTree.build_minimal
      end

      it "returns the home page" do
        Page.find_by_id(@home.id).should eq @home
      end

      it "returns the parent page" do
        Page.find_by_id(@parent.id).should eq @parent
      end
    end

    context "when pages do not exist" do
      it "returns nil" do
        Page.find_by_id('no-such-id').should be_nil
      end
    end

  end

  describe ".find_by_id!" do

    context "when pages exist" do
      before do
        @home, @parent = StandardTree.build_minimal
      end

      it "returns the home page" do
        Page.find_by_id(@home.id).should eq @home
      end

      it "returns the parent page" do
        Page.find_by_id(@parent.id).should eq @parent
      end
    end

    context "when pages do not exist" do
      it "raises Page::NotFound" do
        lambda {
          Page.find_by_id!('no-such-id')
        }.should raise_error Page::NotFound
      end

    end
  end

  describe ".home" do

    context "when pages exist" do
      before do
        @home, @parent = StandardTree.build_minimal
      end

      it "returns the home page" do
        Page.home.should eq @home
      end
    end

    context "when pages do not exist" do
      it "raises Page::NotFound" do
        lambda {
          Page.home
        }.should raise_error Page::NotFound
      end
    end
  end

end
