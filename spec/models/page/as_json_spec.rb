require 'spec_helper'

describe Page, "#as_json" do

  let :slice_json do
    page_json[:slices].first
  end

  context "with no arguments" do
    let :page do
      StandardTree.build_minimal_with_slices.last
    end

    let :page_json do
      page.as_json
    end

    let :slice do
      page.slices.first
    end

    it "has page attributes" do
      page_json.should include({
        id: page.id,
        name: page.name,
        permalink: page.permalink
      })
    end

    it "has slice attributes" do
      slice_json.should include({
        title: slice.title
      })
    end
  end

  context "specifiying :slice_embed" do
    let :page do
      home, parent = StandardTree.build_minimal
      SetPage.make(
        parent: home,
        name: 'Articles',
        permalink: 'articles',
        layout: 'layout_one'
      ).tap do |page|
        page.set_slices << TextileSlice.new(
          textile: 'I appear above every article.',
          container: 'container_one'
        )
      end
    end

    let :page_json do
      page.as_json(slice_embed: :set_slices)
    end

    let :slice do
      page.set_slices.first
    end

    it "has page attributes" do
      page_json.should include({
        id: page.id,
        name: page.name,
        permalink: page.permalink
      })
    end

    it "has slice attributes" do
      slice_json.should include({
        textile: slice.textile
      })
    end
  end
end
