require 'spec_helper'

describe Page, type: :model do
  describe ".find_by_path" do

    context "when pages exist" do

      before do
        @home, @parent = StandardTree.build_minimal
      end

      it "returns the home page" do
        expect(Page.find_by_path('/')).to eq @home
      end

      it "returns the parent page" do
        expect(Page.find_by_path('/parent')).to eq @parent
      end

      it "returns the child page" do
        child, grand_child = StandardTree.add_complex(@home, @parent)
        expect(Page.find_by_path('/parent/child')).to eq child
      end

      it "returns the grand child page" do
        child, grand_child = StandardTree.add_complex(@home, @parent)
        expect(Page.find_by_path('/parent/child/grand-child')).to eq grand_child
      end
    end

    context "when pages do not exist" do
      it "raises Page::NotFound" do
        expect {
          Page.find_by_path('no-such-page')
        }.to raise_error Page::NotFound
      end
    end
  end
end

describe Page, ".home" do

  context "when pages exist" do
    before do
      @home, @parent = StandardTree.build_minimal
    end

    it "returns the home page" do
      expect(Page.home).to eq @home
    end
  end

  context "when pages do not exist" do
    it "raises Page::NotFound" do
      expect {
        Page.home
      }.to raise_error Page::NotFound
    end
  end
end
