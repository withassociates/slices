require 'spec_helper'

describe 'Slices::Asset::Maker' do

  before do
    Slices::Config.stub(s3_storage?: false)
  end

  let :args do
    double(:args)
  end

  let :maker do
    Slices::Asset::Maker.new(args)
  end

  describe ".create_new_asset" do
    it "creates a new asset" do
      new_asset = Asset.new
      expect(Asset).to receive(:create!).with(args).and_return(new_asset)

      expect(maker.create_new_asset).to eq new_asset
    end
  end

  describe ".find_matching_asset" do
    it "looks for a mathching asset" do
      new_asset = double(:new_asset).as_null_object
      maker.stub(new_asset: new_asset)
      matching_asset = double(:matching_asset).as_null_object

      expect(Asset).to receive(:where).and_return(stub(first:matching_asset))
      expect(maker.find_matching_asset(new_asset)).to eq matching_asset
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
      expect(maker.s3_path).to eq 'uploads/1357556804706/window.jpg'
    end
  end

  describe ".run" do
    let :new_asset do
      double(:new_asset).as_null_object
    end

    before do
      expect(Asset).to receive(:create!).with(args).and_return(new_asset)
    end

    context "when a matching asset does not exist" do
      it "creates a new asset" do
        expect(maker).to receive(:find_matching_asset).and_return(nil)
        expect(maker.run).to eq new_asset
      end
    end

    context "when a matching asset is found" do
      let :matching_asset do
        double(:matching_asset,
             present?: true
            ).as_null_object
      end

      before do
        expect(maker).to receive(:find_matching_asset).and_return(matching_asset)
      end

      it "creates a new asset" do
        expect(maker.run).to eq matching_asset
      end

      it "makes sure the matching asset is soft restored" do
        expect(matching_asset).to receive :soft_restore!
        maker.run
      end

      it "destroys the new asset" do
        expect(new_asset).to receive(:destroy)
        maker.run
      end
    end

  end
end
