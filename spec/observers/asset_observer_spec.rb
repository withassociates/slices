require 'spec_helper'

describe AssetObserver do

  let :asset do
    double.as_null_object
  end

  subject do
    AssetObserver.instance
  end

  context "#after_validation" do
    it "updates machine tags" do
      expect(asset).to receive :update_page_cache
      subject.after_validation asset
    end
  end

end

