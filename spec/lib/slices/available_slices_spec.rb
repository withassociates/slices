require 'spec_helper'

shared_examples_for "a valid slice description" do
  it "does not describe _type" do
    expect(slice).not_to include '_type'
  end

  it "does not describe _id" do
    expect(slice).not_to include '_id'
  end

  it "does not describe position" do
    expect(slice).not_to include 'position'
  end
end

describe Slices::AvailableSlices do

  describe ".all" do

    let :all do
      Slices::AvailableSlices.all
    end

    it "finds slices" do
      expect(all.length).to be > 1
    end

    it "has slices in alphabetical order" do
      names = all.values.map { |hash| hash['name'] }
      (names.size - 1).times do |i|
        expect(names[i] <=> names[i + 1]).to eq -1
      end
    end

    it "does not consider SetSlice to be available to the user" do
      expect(all).not_to include 'set'
    end

    context "when describing SlideshowSlice" do
      let :slice do
        all['slideshow']
      end

      it_behaves_like "a valid slice description"

      it "tells me the slice's name" do
        expect(slice['name']).to eq('Slideshow')
      end

      it "tells me where to find the slice's template" do
        expect(slice['template']).to eq('slideshow/slideshow')
      end

      it "tells me if the slice is restricted" do
        expect(slice['restricted']).to be_falsey
      end

      it "tells me the default for attachment 'slides'" do
        expect(slice['slides']).to eq([])
      end
    end

    context "when describing TextileSlice" do
      let :slice do
        all['textile']
      end

      it_behaves_like "a valid slice description"

      it "tells me the slice's name" do
        expect(slice['name']).to eq('Textile')
      end

      it "tells me where to find the slice's template" do
        expect(slice['template']).to eq('textile/textile')
      end

      it "tells me if the slice is restricted" do
        expect(slice['restricted']).to be_falsey
      end

      it "tells me the default for field 'body'" do
        expect(slice['body']).to eq(nil)
      end
    end
  end

end

