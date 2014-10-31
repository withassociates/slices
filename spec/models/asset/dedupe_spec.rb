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

    end

  end
end
