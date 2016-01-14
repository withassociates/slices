require 'spec_helper'

describe Attachment, type: :model do
  describe "#as_json" do

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
