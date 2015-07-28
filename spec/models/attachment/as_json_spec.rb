require 'spec_helper'

describe Attachment, type: :model do
  describe "#as_json" do

    it "has attachment attributes" do
      attachment = Attachment.new

      expect(attachment.as_json).to include({
        _id: attachment.id.to_s,
      })
    end

    context "when attachment has an asset" do
      let :asset do
        Asset.new
      end

      it "has asset attributes" do
        attachment = Attachment.new(asset: asset)

        expect(attachment.as_json).to include({
          asset_id: asset.id.to_s,
          asset: asset.as_json,
        })
      end
    end

    context "when attachment has a localised field" do

      let :klass do
        Class.new(Attachment) do
          field :foo, localize: true
        end
      end

      let :attachment do
        klass.new(foo_translations: {'en' => "en foo", 'de' => "de foo"})
      end

      it "returns the localised version of the field" do
        expect(attachment.as_json[:foo]).to eq "en foo"

        I18n.with_locale(:de) do
          expect(attachment.as_json[:foo]).to eq "de foo"
        end
      end
    end

  end
end
