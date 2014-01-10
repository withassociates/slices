require 'spec_helper'

shared_examples_for "a valid slice description" do
  it "does not describe _type" do
    slice.should_not include '_type'
  end

  it "does not describe _id" do
    slice.should_not include '_id'
  end

  it "does not describe position" do
    slice.should_not include 'position'
  end
end

describe Slices::AvailableSlices do

  describe ".all" do

    let :all do
      Slices::AvailableSlices.all
    end

    it "finds slices" do
      all.length.should be > 1
    end

    it "has slices in alphabetical order" do
      names = all.values.map { |hash| hash['name'] }
      (names.size - 1).times do |i|
        (names[i] <=> names[i + 1]).should eq -1
      end
    end

    it "does not consider SetSlice to be available to the user" do
      all.should_not include 'set'
    end

    context "when describing SlideshowSlice" do
      let :slice do
        all['slideshow']
      end

      it_behaves_like "a valid slice description"

      it "tells me the slice's name" do
        slice['name'].should == 'Slideshow'
      end

      it "tells me where to find the slice's template" do
        slice['template'].should == 'slideshow/slideshow'
      end

      it "tells me if the slice is restricted" do
        slice['restricted'].should be_false
      end

      it "tells me the default for field 'slides'" do
        slice['slides'].should == []
      end
    end

    context "when describing TextileSlice" do
      let :slice do
        all['textile']
      end

      it_behaves_like "a valid slice description"

      it "tells me the slice's name" do
        slice['name'].should == 'Textile'
      end

      it "tells me where to find the slice's template" do
        slice['template'].should == 'textile/textile'
      end

      it "tells me if the slice is restricted" do
        slice['restricted'].should be_false
      end

      it "tells me the default for field 'body'" do
        slice['body'].should == nil
      end
    end
  end

end

