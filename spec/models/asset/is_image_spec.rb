require 'spec_helper'

describe Asset do
  describe "#is_image?" do

    context "when asset is an image" do
      let :asset do
        Asset.new(
          file_content_type: 'image/jpeg'
        )
      end

      it "is an image?" do
        asset.is_image?.should be_true
      end
    end

    context "when asset is a file" do
      let :asset do
        Asset.new(
          file_content_type: 'application/pdf'
        )
      end

      it "is an image?" do
        asset.is_image?.should be_false
      end

    end
  end
end
