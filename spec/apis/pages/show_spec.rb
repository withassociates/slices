require 'spec_helper'

describe "GET to pages#show" do

  include_context "signed in as admin"

  context "a normal page" do
    before do
      home, @page = StandardTree.build_minimal_with_slices
      get admin_page_path(@page, format: :json)
    end

    it "responds with success" do
      response.code.should eq '200'
    end

    it "has page attributes" do
      json_response.should include({'name' => 'Parent'})
      json_response.should include({'layout' => 'default'})
    end

    it "has slice attributes" do
      json_slices[0].should include({'title' => 'Title'})
      slice_id = @page.slices.first.id.to_s
      json_slices[0].should include({'id' => slice_id})
    end
  end

  context "as set entry page" do

    before do
      home, parent = StandardTree.build_minimal
      @page, articles = StandardTree.add_article_set(home)
      get admin_page_path(@page, format: 'json'), entries: 1
    end

    it "includes set's entry content slices" do
      slice = json_slices.find { |slice| slice['type'] == 'placeholder' }
      slice.should be
    end

    it "does not display include information for set page" do
      json_response.should_not include :name
    end
  end

end

