require 'spec_helper'

describe Slice, type: :model do
  describe "#write_attributes" do

    context "when the slice has an embedded relation" do
      class Embeddable
        include Mongoid::Document
        embedded_in :test_slice
        field :data
      end

      class TestSlice < Slice
        embeds_many :embeddables
      end

      let(:slice) { TestSlice.new(normal_page: Page.new) }
      let(:embedded_attrs) { {data: "data"} }
      let(:slice_attrs) { {embeddables: [embedded_attrs]} }

      subject do
        slice.write_attributes(slice_attrs)
        slice.embeddables[0]
      end

      it "stores the data" do
        expect(subject.data).to eq "data"
      end

      it "creates a new embeddable" do
        expect(subject).to be_new_record
      end

      context "when the embeddable already exists" do
        let(:embeddable) { Embeddable.new(data: "old") }
        before { slice.embeddables = [embeddable] }
        let :embedded_attrs do
          {
            _id: embeddable.id,
            data: "new"
          }
        end

        it "updates the embeddable" do
          expect(subject.data).to eq("new")
        end

        context "when embeddable field is not present in attributes" do
          let(:slice_attrs) { {} }

          it "doesn't change embeddable" do
            expect(subject.data).to eq("old")
          end
        end

        context "when embeddable field is nil in attributes" do
          let(:slice_attrs) { {embeddables: nil} }

          it "deletes embeddable" do
            expect(subject).to be_nil
          end
        end
      end
    end

  end
end
