require 'spec_helper'

describe Asset, "on create duplicate images are checked for" do

  let :asset do
    Asset.make(file: file_fixture)
  end

  context "on creation" do

    let :new_asset do
      Asset.make(file: file_fixture)
    end

    it "returns the same id for new asset with the same image" do
      asset.id.should eq new_asset.id
    end

    context "for a soft deleted asset" do
      before do
        asset.soft_destroy!
      end

      it "returns the same id for new asset with the same image" do
        asset.id.should eq new_asset.id
      end

      it "should not be soft destroyed" do
        new_asset.should_not be_soft_destroyed
      end
    end

  end

end
