require 'spec_helper'

describe Slices::Serialization, ".for_json" do
  it "serializes pages and their content into a hash" do
    class TestSlice < Slice
      field :text, type: String, localize: true
      embeds_many :strict_embeds, class_name: "TestEmbed"
    end

    class TestEmbed
      include Mongoid::Document
      field :text, type: String, localize: true
    end

    page = Page.new(
      name: "Foo",
      title: "Foo",
      layout: "default",
      show_in_nav: true,
      active: true,
      slices: [
        slice = TestSlice.new(
          position: 0,
          text: "Bar",
          strict_embeds: [
            strict_embed = TestEmbed.new(
              text: "Baz"
            )
          ],
          casual_embeds: [
            casual_embed = TestEmbed.new(
              text: "Qux"
            )
          ]
        )
      ]
    )

    result = Slices::Serialization.for_json(page)

    expect(result).to eq(
      "active" => true,
      "asset_ids" => [],
      "author_id" => nil,
      "created_at" => nil,
      "external_url" => "",
      "has_content" => false,
      "id" => page.id.to_s,
      "layout" => "default",
      "meta_description" => nil,
      "name" => "Foo",
      "page_id" => nil,
      "path" => nil,
      "position" => nil,
      "role" => nil,
      "show_in_nav" => true,
      "slices" => [{
        "container" => nil,
        "id" => slice.id.to_s,
        "position" => 0,
        "strict_embeds" => [{
          "id" => strict_embed.id.to_s,
          "text" => "Baz"
        }],
        "text" => "Bar",
        "type" => "test",
      }],
      "title" => "Foo",
      "updated_at" => nil,
    )

    Object.send(:remove_const, :TestSlice)
    Object.send(:remove_const, :TestEmbed)
  end
end
