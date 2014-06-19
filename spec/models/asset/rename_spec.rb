require 'spec_helper'

describe "Renaming an asset", type: :model do

  context "with a simple name" do
    let :asset do
      Asset.make file: file_fixture
    end

    before do
      asset.name = "Cute Ladybird"
      asset.save!
    end

    it "ensures the extension is maintained" do
      expect(asset.name).to eq("Cute_Ladybird.jpg")
    end

    it "alters the file name accordingly" do
      expect(asset.file_file_name).to eq("Cute_Ladybird.jpg")
    end

    it "moves the file on storage" do
      expect(asset.file.exists?).to be_truthy
    end
  end

  context "with a dangerous name" do
    let :asset do
      Asset.make file: file_fixture, name: '../../../Ladybird/ladybug_1'
    end

    it "sanitizes the problem characters" do
      expect(asset.file_file_name).to eq(".._.._.._Ladybird_ladybug_1.jpg")
    end

    it "manages to store the file" do
      expect(asset.file.exists?).to be_truthy
    end
  end

  context "when changing case only" do
    let :asset do
      Asset.make file: file_fixture
    end

    before do
      asset.name = 'Ladybird.jpg'
      asset.save!
    end

    it "obeys the new case" do
      expect(asset.file_file_name).to eq("Ladybird.jpg")
    end

    it "actually moves the file" do
      expect(asset.file.path).to match /Ladybird.jpg$/
      expect(asset.file.exists?).to be_truthy
    end
  end

end

