require 'spec_helper'

describe Asset, type: :model do
  describe "#is_image?" do

    context "when asset is an image" do
      let :asset do
        Asset.new(
          file_content_type: 'image/jpeg'
        )
      end

      it "is an image?" do
        expect(asset.is_image?).to be_truthy
      end
    end

    context "when asset is a file" do
      let :asset do
        Asset.new(
          file_content_type: 'application/pdf'
        )
      end

      it "is an image?" do
        expect(asset.is_image?).to be_falsey
      end

    end
  end
end
