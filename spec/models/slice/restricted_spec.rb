require 'spec_helper'

describe Slice, ".restricted" do

  class TestSlice < Slice; end
  class RestricedSlice < Slice;
    restricted_slice
  end

  context "A restricted slice" do
    it "be restricted" do
      RestricedSlice.should be_restricted
    end
  end

  context "A normal slice" do
    it "is not restricted" do
      TestSlice.should_not be_restricted
    end
  end

end

