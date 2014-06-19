require 'spec_helper'

describe Slices::HasSlices do
  describe "#ordered_slices" do

    let :page do
      SetPage.create!(name: 'content')
    end

    def slice_options(options)
      {
        title: "t#{options[:position]}",
        container: "container_one",
        position: options[:position]
      }
    end

    before do
      page.slices.build(slice_options(position: 3), TitleSlice)
      page.slices.build(slice_options(position: 1), TitleSlice)
      page.slices.build(slice_options(position: 2), TitleSlice)
    end

    it "return slices in order" do
      ordered_titles = %w(t1 t2 t3)
      expect(page.ordered_slices.map(&:title)).to eq ordered_titles
    end
  end
end
