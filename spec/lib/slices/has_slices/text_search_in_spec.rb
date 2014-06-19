require 'spec_helper'

describe Slices::HasSlices do
  describe ".text_search_in" do

    class DummySlice < Slice
      field :title, type: String
      field :dummy_id, type: String
    end

    def make_slice(title, position)
      DummySlice.new(
        title: title,
        container: "container_one",
        dummy_id: "1234"
      )
    end

    before do
      # When calling MongoSearch::Searchable class methods in a test
      # case we want to make sure that any changes that we make to the
      # class don't persist between test cases. Hence the creation of a
      # new class every time.
      #
      class DummyPage < Page
        text_search_in :title
      end
    end

    let :page do
      DummyPage.new(name: 'dummy').tap do |page|
        page.slices << make_slice("Hello", 3)
      end
    end

    context "and slice has no special search behaviour" do
      before do
        page.save!
      end

      it "search contents of String fields" do
        expect(DummyPage.text_search("Hello").first).to eq page
      end

      it "not search on container or id fields" do
        expect(DummyPage.text_search("container").first).to eq nil
        expect(DummyPage.text_search("1234").first).to eq nil
      end
    end

    context "and slice defines search_text method" do
      before do
        slice = page.slices.first
        def slice.search_text
          "shoes"
        end
        page.save!
      end

      it "not search on String fields" do
        expect(DummyPage.text_search("Hello").first).to eq nil
      end

      it "search on search_text" do
        expect(DummyPage.text_search("shoes").first).to eq page
      end
    end
  end
end
