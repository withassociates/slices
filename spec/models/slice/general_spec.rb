require 'spec_helper'

describe Slice, type: :model do

  context "has a template" do

    class TestSlice < Slice; end
    class TestSetSlice < SetSlice; end
    class TestShowSlice < Slice; end

    it "is able to find its templates" do
      expect(TestSlice.new.template_path).to eq File.join(*%w[test views show])
      expect(TestShowSlice.new.template_path).to eq File.join(*%w[test_set views show])
      expect(TestSetSlice.new.template_path).to eq File.join(*%w[test_set views set])
    end
  end

  context "marked as deleted" do
    let :slice do
      Slice.new('_deleted' => true)
    end

    it "is deleteable" do
      expect(slice).to be_to_delete
    end
  end

end

