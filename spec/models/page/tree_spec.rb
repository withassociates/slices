require 'spec_helper'

describe Page, type: :model do

  context "tree building" do

    before do
      home = Page.create!(name: 'Home', path: '/')
      parent = Page.create!(name: 'Parent', path: '/parent')

      parent.parent = home
      parent.save
      home.save

      @home = Page.find(home.id)
      @parent = Page.find(parent.id)
    end

    it "does not set page on home" do
      expect(@home.parent).to be_nil
    end

    it "has @home as @parent.page" do
      expect(@home).to eq @parent.parent
    end

    it "includes @parent in @home.children" do
      expect(@home.children.entries).to include @parent
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
        expect(home).to be_home
      end

      it "has no parent" do
        expect(home.parent).to be_nil
      end

      it "has no any siblings" do
        expect(home.siblings).to eq []
      end

      it "is not a first sibling" do
        expect(home).not_to be_first_sibling
      end

      it "is not a last sibling" do
        expect(home).not_to be_last_sibling
      end

      it "has parent as a child" do
        expect(home.children.entries).to include parent
      end
    end

    context "the parent page" do
      it "is not the home page" do
        expect(parent).not_to be_home
      end

      it "has a parent" do
        expect(parent.parent).to eq Page.home
      end

      it "has children" do
        expect(parent.children.entries).to eq [child, sibling, youngest]
      end
    end

    context "the child page (parent's first child)" do

      it "is the first sibling" do
        expect(child).to be_first_sibling
      end

      it "is not the last s a next sibling" do
        expect(child).not_to be_last_sibling
      end

      it "has no previous sibling" do
        expect(child.previous_sibling).to be_nil
      end

      it "has sibling as the next sibling" do
        expect(child.next_sibling).to eq sibling
      end

      it "has siblings" do
        expect(child.siblings.entries).to eq [sibling, youngest]
      end
    end

    context "the sibling page (parent's middle child)" do

      it "is not the first sibling" do
        expect(sibling).not_to be_first_sibling
      end

      it "is not the last sibling" do
        expect(sibling).not_to be_last_sibling
      end

      it "has sibling as the previous sibling" do
        expect(sibling.previous_sibling).to eq child
      end

      it "has youngest as the next sibling" do
        expect(sibling.next_sibling).to eq youngest
      end

      it "has siblings" do
        expect(sibling.siblings.entries).to eq [child, youngest]
      end
    end

    context "the youngest page (parent's youngest child)" do

      it "is not the first sibling" do
        expect(youngest).not_to be_first_sibling
      end

      it "is the last sibling" do
        expect(youngest).to be_last_sibling
      end

      it "has a previous sibling" do
        expect(youngest.previous_sibling).to eq sibling
      end

      it "has no next sibling" do
        expect(youngest.next_sibling).to be_nil
      end

      it "has siblings" do
        expect(youngest.siblings.entries).to eq [child, sibling]
      end
    end
  end

  context "translated sites" do
    before do
      @home, @parent = StandardTree.build_minimal
      allow(Slices::Translations).to receive(:all).and_return(
        en: 'English',
        de: 'German'
      )
      @_original_locale = I18n.locale
    end

    after do
      I18n.locale = @_original_locale
    end

    it "finds pages from their localized paths" do
      I18n.locale = :en
      expect(Page.find_by_localized_path('/en')).to eq @home
      expect(Page.find_by_localized_path('/en/parent')).to eq @parent
      I18n.locale = :de
      expect(Page.find_by_localized_path('/de')).to eq @home
      expect(Page.find_by_localized_path('/de/parent')).to eq @parent
    end
  end

end
