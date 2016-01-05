require 'spec_helper'

describe Slice, type: :model do
  describe "#cache_key" do
    let :slice do
      Slice.new
    end

    context "when it is embedded as a slice" do
      before do
        allow(slice).to receive(:page) { double(cache_key: 'asdfghjkl') }
      end

      it "should include the page cache key" do
        expect(slice.cache_key).to include 'asdfghjkl'
      end
    end

    context "when it is embedded as a set slice" do
      before do
        allow(slice).to receive(:page) { double(cache_key: 'asdfghjkl') }
        allow(slice).to receive(:set_page) { double(cache_key: '123456789') }
      end

      it "should include both the page and set page cache keys" do
        expect(slice.cache_key).to include 'asdfghjkl'
        expect(slice.cache_key).to include '123456789'
      end
    end

    context "when the slice is not embeded in a page" do
      it "should only have the slice id as the key name" do
        expect(slice.cache_key).to eq "slice/new"
      end
    end
  end
end
