require 'spec_helper'

describe Slices::HasAttachments do

  class TestSlide < Attachment; end;

  let :asset do
    double id: 1,
      as_json: { "id" => 1 }
  end

  class DefaultSliceClass
    include Mongoid::Document
    include Slices::HasAttachments
    has_attachments
  end

  let :slice do
    DefaultSliceClass.new
  end

  context "#attachments" do
    context "with custom name and class" do

      class CustomSlice
        include Mongoid::Document
        include Slices::HasAttachments
        has_attachments :slides, class_name: 'TestSlide'
      end

      subject do
        CustomSlice.new(
          slides: [{asset_id: asset.id}]
        )
      end

      it "has TestSlide attachments" do
        expect(subject.slides.first).to be_a TestSlide
      end
    end

    context "with defaults" do
      subject do
        DefaultSliceClass.new(
          attachments: [{asset_id: asset.id}]
        )
      end

      it "has Attachment attachments" do
        expect(subject.attachments.first).to be_a Attachment
      end
    end
  end

  describe "#as_json" do

    class SuperClass
      include Mongoid::Document

      def as_json *args
        super.merge("super" => true)
      end

      include Slices::HasAttachments

    end

    class SubClass < SuperClass
      has_attachments
    end

    let :attachment do
      Attachment.new
    end

    let :slice do
      SubClass.new
    end

    context "with attachments" do
      subject do
        slice.attachments = [attachment]
        slice.as_json
      end

      it "calls as_json on the superclass" do
        expect(subject["super"]).to eq(true)
      end

      it "merges attachments into an array" do
        expect(subject[:attachments]).to be_an Array
      end

      it "calls as_json on attachments" do
        expect(subject[:attachments].first).to eq(attachment.as_json)
      end

    end

    context "with no attachments" do
      subject do
        slice.as_json
      end

      it "returns an empty array" do
        expect(subject[:attachments]).to be_an Array
      end

    end

  end

  describe "#attachment_asset_ids" do

    let :asset_id do
      BSON::ObjectId.new
    end

    let :other_asset_id do
      BSON::ObjectId.new
    end

    let :attachment do
      double asset_id: asset_id
    end

    let :other_attachment do
      double asset_id: other_asset_id
    end

    context "on a slide" do

      context "with two attachments" do
        subject do
          allow(slice).to receive(:attachments).and_return([attachment, other_attachment])
          slice.attachment_asset_ids
        end

        it "is an array of asset_ids" do
          expect(subject).to eq [asset_id, other_asset_id]
        end

      end

      context "with an attachment missing an asset_id" do
        let :broken_attachment do
          double asset_id: nil
        end

        subject do
          allow(slice).to receive(:attachments).and_return([broken_attachment])
          slice.attachment_asset_ids
        end

        it "is an empty array" do
          expect(subject).to eq []
        end

      end

      context "with no attachments" do
        subject do
          slice.attachment_asset_ids
        end

        it "is an empty array" do
          expect(subject).to eq []
        end

      end
    end

    context "on a page with slices but no attachments" do

      let :asset_id do
        BSON::ObjectId.new
      end

      let :attachment do
        double "Attachment", asset_id: asset_id
      end

      let :textile_slice do
        TextileSlice.new
      end

      let :page do
        Page.new.tap do |page|
          page.slices << slice
          page.slices << textile_slice
        end
      end

      subject do
        allow(slice).to receive(:attachments).and_return([attachment])
        page.attachment_asset_ids
      end

      it "is an array of asset_ids" do
        expect(subject).to eq [asset_id]
      end

    end

    context "on a page with attachments and slices" do

      let :slice_asset_id do
        BSON::ObjectId.new
      end

      let :page_asset_id do
        BSON::ObjectId.new
      end

      let :slice_attachment do
        double "Attachment", asset_id: slice_asset_id
      end

      let :page_attachment do
        double "Attachment", asset_id: page_asset_id
      end

      let :textile_slice do
        TextileSlice.new
      end

      let :page_class do
        Class.new(Page) do
          include Slices::HasAttachments
          has_attachments
        end
      end

      context "with different assets on page and slice" do
        let :page do
          page_class.new.tap do |page|
            page.slices << slice
            page.slices << textile_slice
          end
        end

        subject do
          allow(page).to receive(:attachments).and_return([page_attachment])
          allow(slice).to receive(:attachments).and_return([slice_attachment])
          page.attachment_asset_ids
        end

        it "is an array of asset_ids" do
          expect(subject).to eq [page_asset_id, slice_asset_id]
        end

      end

      context "with the same assets on page and slice" do
        let :page do
          page_class.new.tap do |page|
            page.slices << slice
            page.slices << textile_slice
          end
        end

        before do
          allow(page).to receive(:attachments).and_return([page_attachment])
          allow(slice).to receive(:attachments).and_return([page_attachment, slice_attachment])
        end

        subject do
          page.attachment_asset_ids
        end

        it "is an array of asset_ids" do
          expect(subject).to eq [page_asset_id, slice_asset_id]
        end

      end

      context "on a page with missing assets" do
        let :page do
          page_class.new
        end

        before do
          expect(page).to receive(:attachment_asset_ids).and_return [page_asset_id]
        end

        subject do
          page.attachment_assets
        end

        it "is an empty array" do
          expect(subject).to eq []
        end
      end
    end

  end

  context "#slice_attachment_ids" do

    let :slice_asset_id do
      BSON::ObjectId.new
    end

    let :page_asset_id do
      BSON::ObjectId.new
    end

    let :slice_attachment do
      double "Attachment", asset_id: slice_asset_id
    end

    let :page_attachment do
      double "Attachment", asset_id: page_asset_id
    end

    let :textile_slice do
      TextileSlice.new
    end

    let :page_class do
      Class.new(Page) do
        include Slices::HasAttachments
        has_attachments
      end
    end

    context "on a page with an attachment slice and a non-attachemnt slice" do
      let :page do
        page_class.new.tap do |page|
          page.slices << slice
          page.slices << textile_slice
        end
      end

      subject do
        allow(slice).to receive(:attachments).and_return([slice_attachment])
        page.slice_attachment_asset_ids
      end

      it "is an array of asset_ids" do
        expect(subject).to eq [slice_asset_id]
      end

    end

    context "on a page with an attachment slice" do
      let :page do
        page_class.new.tap do |page|
          page.slices << slice
        end
      end

      subject do
        allow(slice).to receive(:attachments).and_return([slice_attachment])
        page.slice_attachment_asset_ids
      end

      it "is an array of asset_ids" do
        expect(subject).to eq [slice_asset_id]
      end

    end

    context "with the same assets on two different slices" do

      let :other_slice do
        DefaultSliceClass.new
      end

      let :page do
        page_class.new.tap do |page|
          page.slices << slice
          page.slices << other_slice
        end
      end

      before do
        expect(slice).to receive(:attachments).and_return([slice_attachment])
        expect(other_slice).to receive(:attachments).and_return([slice_attachment])
      end

      subject do
        page.slice_attachment_asset_ids
      end

      it "is an array of asset_ids" do
        expect(subject).to eq [slice_asset_id]
      end

    end

    context "on a page with no slices" do
      let :page do
        page_class.new
      end

      subject do
        page.slice_attachment_asset_ids
      end

      it "is an empty array" do
        expect(subject).to eq []
      end

    end

  end

end

