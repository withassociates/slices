require 'spec_helper'

describe Asset, type: :model do
  describe "on create duplicate images are checked for" do

    let :asset do
      Asset.make(file: file_fixture)
    end

    context "on creation" do

      let :new_asset do
        Asset.make(file: file_fixture)
      end

      it "returns the same id for new asset with the same image" do
        expect(asset.id).to eq new_asset.id
      end

      context "for a soft deleted asset" do
        before do
          asset.soft_destroy!
        end

        it "returns the same id for new asset with the same image" do
          expect(asset.id).to eq new_asset.id
        end

        it "should not be soft destroyed" do
          expect(new_asset).not_to be_soft_destroyed
        end
      end

    end

  end
end
