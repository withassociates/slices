require 'spec_helper'

describe Slice, type: :model do
  describe ".restricted" do

    class TestSlice < Slice; end
    class RestricedSlice < Slice;
      restricted_slice
    end

    context "A restricted slice" do
      it "be restricted" do
        expect(RestricedSlice).to be_restricted
      end
    end

    context "A normal slice" do
      it "is not restricted" do
        expect(TestSlice).not_to be_restricted
      end
    end

  end
end
