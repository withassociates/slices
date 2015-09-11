require 'spec_helper'

shared_examples "updates slices correctly" do
  it "removes deleted slices" do
    expect(json_slices.find { |slice| slice['id'] == @deleted_slice_id }).to be_nil
  end

  it "removes _new from new slices" do
    container_one_slices, new_slice = container_one_slices_and_new_slice

    expect(new_slice['_new']).to be_nil
  end

  it "does not use client_id for id in new slices" do
    container_one_slices, new_slice = container_one_slices_and_new_slice

    expect(new_slice['client_id']).not_to eq new_slice['id']
  end

  it "orders slices correctly" do
    container_one_slices, new_slice = container_one_slices_and_new_slice

    expect(container_one_slices.first['id']).to eq new_slice['id']
    expect(container_one_slices.second['id']).to eq @updated_slice_id
  end
end

describe "PUT to pages#update" do

  def new_slice
    {
      '_new'        => 1,
      'client_id'   => 'new_123',
      'type'        => 'title',
      'position'    => 0,
      'title'       => 'New content',
      'container'   => 'new_container_one'
    }
  end

  def new_slideshow_slice
    slide = {
      'asset_id'    => '4f0ead1cf622394081000004',
      'caption'     => '',
    }

    {
      'client_id'   => 'new_124',
      '_new'        => 1,
      'type'        => 'slideshow',
      'position'    => 0,
      'container'   => 'container_one',

      'slides'      => [ slide ],
    }
  end

  def content_slices_data(slices)
    @updated_slice_id = slices.first.id.to_s
    @deleted_slice_id = slices.last.id.to_s

    updated_slice = { 'id' => @updated_slice_id, 'type' => 'title', 'position' => 1, 'title' => 'Updated Title', 'container' => 'container_one' }
    deleted_slice = { '_destroy' => true, 'id' => @deleted_slice_id, 'type' => 'textile', 'position' => 0, 'textile' => 'h2. Textile Updated', 'container' => 'container_two' }

    [new_slice, updated_slice, deleted_slice]
  end

  def entry_content_slices_data(slices)
    @updated_slice_id = slices.first.id.to_s
    @deleted_slice_id = slices.last.id.to_s

    updated_slice = { 'id' => @updated_slice_id, 'type' => 'textile', 'position' => 1, 'textile' => 'h2. New heading', 'container' => 'container_one' }
    deleted_slice = { '_destroy' => true, 'id' => @deleted_slice_id, 'type' => 'placeholder', 'position' => 0, 'container' => 'container_two' }

    [new_slice, updated_slice, deleted_slice]
  end

  def page_data(slices_data)
    {
      'name'              => 'Updated parent',
      'permalink'         => 'parent',
      'active'            => 1,
      'show_in_nav'       => 0,
      'layout'            => 'layout_three',
      'meta_description'  => 'This is an important page',
      'title'             => 'Title',
      'slices'            => slices_data
    }
  end

  def container_one_slices_and_new_slice
    container_one_slices = json_slices.select { |slice| slice['container'] = 'container_one' }
    new_slice = json_slices.find { |slice| slice['type'] == 'title' && slice['title'] == 'New content' }
    [container_one_slices, new_slice]
  end

  def put_json(path, parameters = nil, headers = nil)
    put path, parameters.to_json, { 'CONTENT_TYPE' => Mime::JSON.to_s }
  end

  include_context "signed in as admin"

  context "with vaild data" do

    before do
      home, @page = StandardTree.build_minimal_with_slices
      slices_data = content_slices_data(@page.slices)
      put_json admin_page_path(@page, format: :json),
        { page: page_data(slices_data) }
    end

    it "responds with success" do
      expect(response.code).to eq '200'
    end

    it_behaves_like "updates slices correctly"

    it "updates page attributes" do
      expect(json_response).to include({'name' => 'Updated parent'})
      expect(json_response).to include({'active' => true})
      expect(json_response).to include({'show_in_nav' => false})
      expect(json_response).to include({'layout' => 'layout_three'})
      expect(json_response).to include({'meta_description' => 'This is an important page'})
      expect(json_response).to include({'title' => 'Title'})
    end

    it "updates slice attributes" do
      updated_slice = json_slices.find { |slice| slice['id'] == @updated_slice_id }
      expect(updated_slice['title']).to eq 'Updated Title'
    end

    it "adds new slices" do
      container_one_slices, new_slice = container_one_slices_and_new_slice

      expect(container_one_slices.length).to eq 2
      expect(new_slice['title']).to eq 'New content'
    end

  end

  context "for a set's entries (with valid data)" do
    before do
      home, parent = StandardTree.build_minimal
      page = SetPage.make(parent: home, permalink: 'blog', name: 'Blog')
      page, articles = StandardTree.add_article_set(home)
      slices_data = entry_content_slices_data(page.set_slices)

      put_json admin_page_path(page, entries: 1, format: :json),
        { page: { 'slices' => slices_data } }
    end

    it "responds with success" do
      expect(response.code).to eq '200'
    end

    it "does not return page attributes" do
      expect(json_response).not_to include 'name'
      expect(json_response).not_to include 'layout'
    end

    it "updates slice attributes" do
      updated_slice = json_slices.find { |slice| slice['id'] == @updated_slice_id }
      expect(updated_slice['textile']).to eq 'h2. New heading'
    end

    it "adds new slices" do
      container_one_slices, new_slice = container_one_slices_and_new_slice

      expect(container_one_slices.length).to eq 2
      expect(new_slice['title']).to eq 'New content'
    end

    it_behaves_like "updates slices correctly"
  end

  context "with validation errors" do

    before do
      home, @page = StandardTree.build_minimal_with_slices
      slices_data = content_slices_data(@page.slices)
      page_data = page_data(slices_data)
      page_data['name'] = ''
      slices_data[0]['title'] = ''
      slices_data[1]['title'] = ''

      put_json admin_page_path(@page, format: :json),
        { page: page_data }
    end

    it "responds with error" do
      expect(response.code).to eq '422'
    end

    it "has errors on page document" do
      expect(json_response).to include({'name' => ["can't be blank"]})
    end

    it "keeps client_id on new slices" do
      expect(json_errors['new_123']).to be
    end

    it "has errors on slices" do
      new_slice = json_errors['new_123']
      expect(new_slice).to include({'title' => ["can't be blank"]})

      updated_slice = json_errors[@updated_slice_id]
      expect(updated_slice).to include({'title' => ["can't be blank"]})
    end

    it "does not remove the deleted slices" do
      page = Page.find(@page.to_param)
      deleted_slice = page.slices.detect { |slice| slice.id.to_s == @deleted_slice_id }
      expect(deleted_slice).to be_a Slice
    end
  end

  context "with validation errors on a deleted slice" do

    before do
      home, page = StandardTree.build_minimal_with_slices
      slices_data = content_slices_data(page.slices)
      slices_data[2]['textile'] = ''

      put_json admin_page_path(page, format: :json),
        { page: page_data(slices_data) }
    end

    it "responds with success" do
      expect(response.code).to eq '200'
    end

    it "removes the delete slices" do
      expect(json_slices.find { |slice| slice['id'] == @deleted_slice_id }).to be_nil
    end
  end

  context "with a new asset slice" do

    before do
      home, page = StandardTree.build_minimal
      slices_data = [new_slideshow_slice]

      put_json admin_page_path(page, format: :json),
        { page: page_data(slices_data) }
    end

    it "responds with success" do
      expect(response.code).to eq '200'
    end

  end

  context "updating an asset slice" do
    let(:slide) { SlideshowSlice::Slide.new(caption: "old") }
    let(:slice) { SlideshowSlice.new(slides: [slide]) }
    let(:page) do
      page = StandardTree.build_minimal.last
      page.slices = [slice]
      page
    end
    let(:slices_data) do
      [
        slice.as_json.merge('slides' => [slide.as_json.merge('caption' => "new")])
      ]
    end

    before do
      put_json admin_page_path(page, format: :json),
        { page: page_data(slices_data) }
    end

    it "responds with success" do
      expect(response.code).to eq '200'
    end

    it "updates the slice" do
      expect(page.reload.slices[0].slides[0].caption).to eq("new")
    end
  end

end

