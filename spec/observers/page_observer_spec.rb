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
        allow(subject).to receive(:attachment_assets_changed?).and_return(true)
        allow(subject).to receive(:did_attachment_assets_change?).and_return(true)
        allow(subject).to receive(:page_changed?).and_return(false)
      end

      it "updates attachement assets" do
        [new_asset, original_asset].each do |double_object|
          expect(double_object).to receive(:reload)
          expect(double_object).to receive(:save)
        end
        expect(page).to receive(:assets=).with([new_asset])

        subject.around_save(page) {}
      end
    end

    context "attachement assets have not changed and neither has page" do

      let :page do
        double(path: '/')
      end

      before do
        allow(subject).to receive(:attachment_assets_changed?).and_return(false)
        allow(subject).to receive(:did_attachment_assets_change?).and_return(false)
        allow(subject).to receive(:page_changed?).and_return(false)
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
        allow(subject).to receive(:attachment_assets_changed?).and_return(false)
        allow(subject).to receive(:did_attachment_assets_change?).and_return(false)
        allow(subject).to receive(:page_changed?).and_return(true)
      end

      it "updates attachement assets" do
        expect(original_asset).to receive(:reload)
        expect(original_asset).to receive(:save)

        subject.around_save(page) {}
      end
    end

  end

  context "#attachment_assets_changed? and #did_attachment_assets_change?" do
    context "attachment_asset_ids and asset_ids differ" do
      let :page do
        double(
          attachment_asset_ids: [Moped::BSON::ObjectId.new],
          asset_ids: [Moped::BSON::ObjectId.new]
        )
      end

      before do
        subject.record = page
      end

      it "is true" do
        expect(subject.attachment_assets_changed?).to be_truthy
      end

      it "memoizes the value in did_attachment_assets_change?" do
        subject.attachment_assets_changed?
        expect(subject.did_attachment_assets_change?).to be_truthy
      end
    end

    context "attachment_asset_ids and asset_ids are equal" do
      let :object_id do
        Moped::BSON::ObjectId.new
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
        expect(subject.attachment_assets_changed?).to be_falsey
      end

      it "memoizes the value in did_attachment_assets_change?" do
        expect(subject.did_attachment_assets_change?).to be_falsey
      end
    end
  end

  context "#page_changed?" do
    context "when the path has changed" do
      let :page do
        double
      end

      before do
        expect(page).to receive(:path_changed?).and_return(true)
        subject.record = page
      end

      it "is true" do
        expect(subject.page_changed?).to be_truthy
      end
    end
  end
end

