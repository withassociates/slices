require 'spec_helper'

describe Page do
  describe ".make" do

    context "when no pages exist" do
      it "returns a page" do
        Page.make(name: 'Home', permalink: '').should be_a Page
      end

      it "returns a home page" do
        home = Page.make(name: 'Home', permalink: '')
        home.should eq Page.home
        home.path.should eq '/'
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
        page.position.should eq 0
      end

      it "returns a page with a parent" do
        page.parent.should eq home
      end

      it "returns a page with a path" do
        page.path.should eq '/parent'
      end

      it "returns a page with the default layout" do
        page.layout.should eq 'default'
      end

      it "returns an entry page with the layout set by the parent" do
        layout = 'two_column'
        home.update_attributes(layout: layout)
        entry = Article.make(name: 'article', parent: home)

        entry.layout.should eq layout
      end
    end

  end
end
