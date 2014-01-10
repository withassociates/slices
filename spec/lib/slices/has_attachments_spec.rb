require 'spec_helper'

describe Slices::HasAttachments do

  class TestSlide < Attachment; end;

  let :asset do
    double id: 1,
      as_json: { "id" => 1 }
  end

  let :default_slice do
    Class.new do
      include Mongoid::Document
      include Slices::HasAttachments
      has_attachments
    end
  end

  let :slice do
    default_slice.new
  end

  context "#write_attributes" do
    let(:caption) { 'Caption' }

    let :attachment_attributes do
      {
        asset_id: asset.id,
        position: 1,
        caption:  caption
      }
    end

    let :slice_attributes do
      {
        attachments: [ attachment_attributes ]
      }
    end

    context "creating a new slice" do

      before do
        slice.write_attributes(slice_attributes)
      end

      subject do
        slice.attributes['attachments'][0]
      end

      it "stores the asset_id" do
        subject[:asset_id].should eq asset.id
      end

      it "stores the caption" do
        subject[:caption].should eq caption
      end

      it "stores the position" do
        subject[:position].should eq 1
      end
    end

  end

  context "#attachments" do
    context "with custom name and class" do

      let :custom_slice do
        Class.new do
          include Mongoid::Document
          include Slices::HasAttachments
          has_attachments :slides, class_name: 'TestSlide'
        end
      end

      subject do
        custom_slice.new(
          slides: [{asset_id: asset.id}]
        )
      end

      it "has TestSlide attachments" do
        subject.slides.first.should be_a TestSlide
      end
    end

    context "with defaults" do
      subject do
        default_slice.new(
          attachments: [{asset_id: asset.id}]
        )
      end

      it "has Attachment attachments" do
        subject.attachments.first.should be_a Attachment
      end
    end
  end

  describe "#as_json" do

    let :super_class do
      Class.new do
        include Mongoid::Document

        def as_json *args
          super.merge("super" => true)
        end

        include Slices::HasAttachments

      end
    end

    let :sub_class do
      Class.new super_class do
        has_attachments
      end
    end

    let :attachment do
      double as_json: { "asset_url" => "/path/to/file.jpg" }
    end

    let :slice do
      sub_class.new
    end

    context "with attachments" do
      subject do
        slice.stub(:attachments => [attachment])
        slice.as_json
      end

      it "calls as_json on the superclass" do
        subject["super"].should == true
      end

      it "merges attachments into an array" do
        subject[:attachments].should be_an Array
      end

      it "calls as_json on attachments" do
        subject[:attachments].first.should == attachment.as_json
      end

    end

    context "with no attachments" do
      subject do
        slice.as_json
      end

      it "returns an empty array" do
        subject[:attachments].should be_an Array
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
          slice.should_receive(:attachments).and_return([attachment, other_attachment])
          slice.attachment_asset_ids
        end

        it "is an array of asset_ids" do
          subject.should eq [asset_id, other_asset_id]
        end

      end

      context "with an attachment missing an asset_id" do
        let :broken_attachment do
          double asset_id: nil
        end

        subject do
          slice.should_receive(:attachments).and_return([broken_attachment])
          slice.attachment_asset_ids
        end

        it "is an empty array" do
          subject.should eq []
        end

      end

      context "with no attachments" do
        subject do
          slice.attachment_asset_ids
        end

        it "is an empty array" do
          subject.should eq []
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
        slice.should_receive(:attachments).and_return([attachment])
        page.attachment_asset_ids
      end

      it "is an array of asset_ids" do
        subject.should eq [asset_id]
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
          page.should_receive(:attachments).and_return([page_attachment])
          slice.should_receive(:attachments).and_return([slice_attachment])
          page.attachment_asset_ids
        end

        it "is an array of asset_ids" do
          subject.should eq [page_asset_id, slice_asset_id]
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
          page.should_receive(:attachments).and_return([page_attachment])
          slice.should_receive(:attachments).and_return([page_attachment, slice_attachment])
        end

        subject do
          page.attachment_asset_ids
        end

        it "is an array of asset_ids" do
          subject.should eq [page_asset_id, slice_asset_id]
        end

      end

      context "on a page with missing assets" do
        let :page do
          page_class.new
        end

        before do
          page.should_receive(:attachment_asset_ids).and_return [page_asset_id]
        end

        subject do
          page.attachment_assets
        end

        it "is an empty array" do
          subject.should eq []
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
        slice.should_receive(:attachments).and_return([slice_attachment])
        page.slice_attachment_asset_ids
      end

      it "is an array of asset_ids" do
        subject.should eq [slice_asset_id]
      end

    end

    context "on a page with an attachment slice" do
      let :page do
        page_class.new.tap do |page|
          page.slices << slice
        end
      end

      subject do
        slice.should_receive(:attachments).and_return([slice_attachment])
        page.slice_attachment_asset_ids
      end

      it "is an array of asset_ids" do
        subject.should eq [slice_asset_id]
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
        subject.should eq []
      end

    end

  end

end

