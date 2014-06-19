require 'spec_helper'

describe Asset, type: :model do

  context "#soft_restore!" do

    let :asset do
      Asset.new(file: file_fixture).tap do |a|
        a.soft_destroy!
      end
    end

    before do
      asset.soft_restore!
    end

    it "is not destroyed" do
      expect(asset).not_to be_soft_destroyed
      expect(asset.reload).not_to be_soft_destroyed
    end

  end

  context "soft restoreed assets" do

    let :otters do
      Asset.make(file: file_fixture)
    end

    let :rubbish do
      Asset.make(file: file_fixture('pepper-pot.jpg'))
    end

    before do
      otters.soft_destroy!
      rubbish.soft_destroy!
      otters.soft_restore!
    end

    context ".ordered_active" do
      subject do
        Asset.ordered_active.entries
      end

      it "does not include soft deleted assets" do
        is_expected.not_to include rubbish
      end

      it "does include other assets" do
        is_expected.to include otters
      end
    end

    context ".search_for" do
      subject do
        Asset.search_for(nil).entries
      end

      it "does not include soft deleted assets" do
        is_expected.not_to include rubbish
      end

      it "does include other assets" do
        is_expected.to include otters
      end
    end
  end

end

