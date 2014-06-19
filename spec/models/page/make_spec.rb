require 'spec_helper'

describe Page, type: :model do
  describe ".make" do

    context "when no pages exist" do
      it "returns a page" do
        expect(Page.make(name: 'Home', permalink: '')).to be_a Page
      end

      it "returns a home page" do
        home = Page.make(name: 'Home', permalink: '')
        expect(home).to eq Page.home
        expect(home.path).to eq '/'
      end
    end

    context "when a page exists" do
      let :home do
        Page.make(name: 'Home', permalink: '')
      end

      let :page do
        Page.make(parent: home, name: 'Parent')
      end

      it "returns a page with a position" do
        expect(page.position).to eq 0
      end

      it "returns a page with a parent" do
        expect(page.parent).to eq home
      end

      it "returns a page with a path" do
        expect(page.path).to eq '/parent'
      end

      it "returns a page with the default layout" do
        expect(page.layout).to eq 'default'
      end

      it "returns an entry page with the layout set by the parent" do
        layout = 'two_column'
        home.update_attributes(layout: layout)
        entry = Article.make(name: 'article', parent: home)

        expect(entry.layout).to eq layout
      end
    end

  end
end
