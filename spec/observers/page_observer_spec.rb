require 'spec_helper'

describe PageObserver do
  subject do
    PageObserver.instance
  end

  context "#around_save" do

    let! :original_asset do
      double :original_asset
    end

    let! :new_asset do
      double :new_asset
    end

    context "attachement assets have changed and page has not changed" do

      let :page do
        double({
          attachment_assets: [new_asset],
          assets: [original_asset],
          path: '/'
        })
      end

      before do
        subject.should_receive(:attachment_assets_changed?).any_number_of_times.and_return(true)
        subject.should_receive(:did_attachment_assets_change?).any_number_of_times.and_return(true)
        subject.should_receive(:page_changed?).any_number_of_times.and_return(false)
      end

      it "updates attachement assets" do
        [new_asset, original_asset].each do |double_object|
          double_object.should_receive(:reload)
          double_object.should_receive(:save)
        end
        page.should_receive(:assets=).with([new_asset])

        subject.around_save(page) {}
      end
    end

    context "attachement assets have not changed and neither has page" do

      let :page do
        double(path: '/')
      end

      before do
        subject.should_receive(:attachment_assets_changed?).any_number_of_times.and_return(false)
        subject.should_receive(:did_attachment_assets_change?).any_number_of_times.and_return(false)
        subject.should_receive(:page_changed?).any_number_of_times.and_return(false)
      end

      it "does not update attachement assets" do
        subject.around_save(page) {}
      end
    end

    context "attachement assets have not changed but the page has" do

      let :page do
        double({
          attachment_assets: [original_asset],
          assets: [original_asset],
          path: '/'
        })
      end

      before do
        subject.should_receive(:attachment_assets_changed?).any_number_of_times.and_return(false)
        subject.should_receive(:did_attachment_assets_change?).any_number_of_times.and_return(false)
        subject.should_receive(:page_changed?).any_number_of_times.and_return(true)
      end

      it "updates attachement assets" do
        original_asset.should_receive(:reload)
        original_asset.should_receive(:save)

        subject.around_save(page) {}
      end
    end

  end

  context "#attachment_assets_changed? and #did_attachment_assets_change?" do
    context "attachment_asset_ids and asset_ids differ" do
      let :page do
        double(
          attachment_asset_ids: [BSON::ObjectId.new],
          asset_ids: [BSON::ObjectId.new]
        )
      end

      before do
        subject.record = page
      end

      it "is true" do
        subject.attachment_assets_changed?.should be_true
      end

      it "memoizes the value in did_attachment_assets_change?" do
        subject.attachment_assets_changed?
        subject.did_attachment_assets_change?.should be_true
      end
    end

    context "attachment_asset_ids and asset_ids are equal" do
      let :object_id do
        BSON::ObjectId.new
      end

      let :page do
        double(
          attachment_asset_ids: [object_id],
          asset_ids: [object_id]
        )
      end

      before do
        subject.record = page
      end

      it "is true" do
        subject.attachment_assets_changed?.should be_false
      end

      it "memoizes the value in did_attachment_assets_change?" do
        subject.did_attachment_assets_change?.should be_false
      end
    end
  end

  context "#page_changed?" do
    context "when the path has changed" do
      let :page do
        double
      end

      before do
        page.should_receive(:path_changed?).and_return(true)
        subject.record = page
      end

      it "is true" do
        subject.page_changed?.should be_true
      end
    end
  end
end

