require 'spec_helper'

describe Slice do

  context "has a template" do

    class TestSlice < Slice; end
    class TestSetSlice < SetSlice; end
    class TestShowSlice < Slice; end

    it "is able to find its templates" do
      TestSlice.new.template_path.should eq File.join(*%w[test views show])
      TestShowSlice.new.template_path.should eq File.join(*%w[test_set views show])
      TestSetSlice.new.template_path.should eq File.join(*%w[test_set views set])
    end
  end

  context "marked as deleted" do
    let :slice do
      Slice.new('_deleted' => true)
    end

    it "is deleteable" do
      slice.should be_to_delete
    end
  end

end

