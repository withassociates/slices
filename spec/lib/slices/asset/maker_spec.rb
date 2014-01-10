require 'spec_helper'

describe 'Slices::Asset::Maker' do

  before do
    Slices::Config.stub(s3_storage?: false)
  end

  let :args do
    stub(:args)
  end

  let :maker do
    Slices::Asset::Maker.new(args)
  end

  describe ".create_new_asset" do
    it "creates a new asset" do
      new_asset = Asset.new
      Asset.should_receive(:create!).with(args).and_return(new_asset)

      maker.create_new_asset.should eq new_asset
    end
  end

  describe ".find_matching_asset" do
    it "looks for a mathching asset" do
      new_asset = stub(:new_asset).as_null_object
      maker.stub(new_asset: new_asset)
      matching_asset = stub(:matching_asset).as_null_object
      Asset.should_receive(:first).and_return(matching_asset)

      maker.find_matching_asset(new_asset).should eq matching_asset
    end
  end

  describe ".s3_path" do
    let :uri do
      URI('https://s3.amazonaws.com/slices-demo/uploads/1357556804706/window.jpg')
    end

    let :args do
      { file: uri }
    end

    it "returns the shortened path from URI" do
      maker.s3_path.should eq 'uploads/1357556804706/window.jpg'
    end
  end

  describe ".run" do
    let :new_asset do
      stub(:new_asset).as_null_object
    end

    before do
      Asset.should_receive(:create!).with(args).and_return(new_asset)
    end

    context "when a matching asset does not exist" do
      it "creates a new asset" do
        Asset.should_receive(:first).and_return(nil)
        maker.run.should eq new_asset
      end
    end

    context "when a matching asset is found" do
      let :matching_asset do
        stub(:matching_asset,
             present?: true
            ).as_null_object
      end

      before do
        Asset.should_receive(:first).and_return(matching_asset)
      end

      it "creates a new asset" do
        maker.run.should eq matching_asset
      end

      it "makes sure the matching asset is soft restored" do
        matching_asset.should_receive :soft_restore!
        maker.run
      end

      it "destroys the new asset" do
        new_asset.should_receive(:destroy)
        maker.run
      end
    end

  end
end
