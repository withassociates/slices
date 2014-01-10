require 'spec_helper'

describe "Old function page controller tests", type: :api do
  include RSpec::Rails::ApiExampleGroup

  include_context "signed in as admin"

  describe "on GET to :new" do

    before do
      home, @page = StandardTree.build_minimal
    end

    it "does not set page type if not set" do
      get new_admin_page_path(parent_id: @page.to_param)
      assert_select 'input[type=hidden][name=type]', count: 0
    end

    it "sets the page type if set" do
      get new_admin_page_path(parent_id: @page.to_param, type: 'article')
      assert_select 'input[type=hidden][name=type][value=article]'
    end
  end

  context "on GET to :show" do

    context "for a existing page" do
      before do
        home, @page = StandardTree.build_minimal_with_slices
        get admin_page_path(@page)
      end

      it "is a success" do
        response.code.should eq '200'
      end
    end

    context "for a missing missing page" do
      before do
        get admin_page_path(id: 'not-found')
      end

      it "redirects to the Site Maps page" do
        response.code.should eq '302'
        response.location.should eq admin_site_maps_url
      end
    end
  end

  describe "POST to :create", type: :api do

    def page_params(parent)
      { parent_id: parent.id.to_s, name: 'A page', layout: 'layout1' }
    end

    before do
      @home, page = StandardTree.build_minimal
    end

    context "with a page" do
      before do
        post admin_pages_path, page: page_params(@home)
      end

      it "responds with redirect" do
        response.code.should eq '302'
      end

      it "creates a new child of home" do
        Page.home.children.length.should eq 2
      end
    end

    context "with an article" do
      before do
        @set_page, articles = StandardTree.add_article_set(@home)
        post admin_pages_path, page: page_params(@set_page), type: 'article'
      end

      it "responds with redirect" do
        response.code.should eq '302'
      end

      it "creates a child of article" do
        @set_page.reload.children.length.should eq 3
      end

      it "creates an article" do
        Page.last.should be_a Article
      end
    end

  end

  describe "on DELETE to :destroy as html" do
    before do
      home, page = StandardTree.build_minimal_with_slices
      delete admin_page_path(page.to_param)
    end

    it "responds with redirect" do
      response.code.should eq '302'
    end
  end
end

