require 'spec_helper'

describe "Renaming an asset" do

  context "with a simple name" do
    let :asset do
      Asset.make file: file_fixture
    end

    before do
      asset.name = "Cute Ladybird"
      asset.save!
    end

    it "ensures the extension is maintained" do
      asset.name.should == "Cute_Ladybird.jpg"
    end

    it "alters the file name accordingly" do
      asset.file_file_name.should == "Cute_Ladybird.jpg"
    end

    it "moves the file on storage" do
      asset.file.exists?.should be_true
    end
  end

  context "with a dangerous name" do
    let :asset do
      Asset.make file: file_fixture, name: '../../../Ladybird/ladybug_1'
    end

    it "sanitizes the problem characters" do
      asset.file_file_name.should == ".._.._.._Ladybird_ladybug_1.jpg"
    end

    it "manages to store the file" do
      asset.file.exists?.should be_true
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
      asset.file_file_name.should == "Ladybird.jpg"
    end

    it "actually moves the file" do
      asset.file.path.should match /Ladybird.jpg$/
      asset.file.exists?.should be_true
    end
  end

end

