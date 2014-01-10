require 'spec_helper'

describe Asset do

  context "#soft_destroy!" do

    let :asset do
      Asset.new(file: file_fixture)
    end

    before do
      asset.soft_destroy!
    end

    it "is destroyed" do
      asset.should be_soft_destroyed
      asset.reload.should be_soft_destroyed
    end

    it "was destroyed at a Time" do
      asset.destroyed_at.should be_a Time
    end

  end

  context "soft destroyed assets" do

    let :otters do
      Asset.make(file: file_fixture)
    end

    let :rubbish do
      Asset.make(file: file_fixture('pepper-pot.jpg'))
    end

    before do
      otters
      rubbish.soft_destroy!
    end

    context ".ordered_active" do
      subject do
        Asset.ordered_active.entries
      end

      it "does not include soft deleted assets" do
        should_not include rubbish
      end

      it "does include other assets" do
        should include otters
      end
    end

    context ".search_for" do
      subject do
        Asset.search_for(nil).entries
      end

      it "does not include soft deleted assets" do
        should_not include rubbish
      end

      it "does include other assets" do
        should include otters
      end
    end
  end

end

