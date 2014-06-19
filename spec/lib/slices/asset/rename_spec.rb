require 'spec_helper'

describe 'Slices::Asset::Rename' do

  describe ".run" do
    it "initializes a Filesystem renamer" do
      file = double(options: {storage: :filesystem})
      new_file_name = 'fn'
      expect_any_instance_of(Slices::Asset::Rename::Filesystem).to receive(:run)

      Slices::Asset::Rename.run file, new_file_name
    end

    it "raises an error for missing renamers" do
      file = double(options: {storage: :unknown})
      expect {
        Slices::Asset::Rename.run file, 'new_file_name'
      }.to raise_error Slices::Asset::Rename::UnsupportedStorage
    end
  end

  describe "Filesystem#rename" do
    it "uses File to rename files" do
      old_path = '/a'
      new_path = '/b'
      file = double(path: old_path).as_null_object
      expect(File).to receive(:rename).with(old_path, new_path)

      renamer = Slices::Asset::Rename::Filesystem.new(file, new_path)
      renamer.rename(:original)
    end
  end

  context "Fog#rename" do
    before do
      Paperclip::Attachment.default_options.merge!( {
        storage: :fog,
        fog_directory: 'directory',
        fog_credentials: {
          provider: 'AWS',
          aws_access_key_id: :aws_access_key_id,
          aws_secret_access_key: :aws_secret_access_key,
        },
      })

      Asset.attachment_definitions[:file][:url] = '/system/:style/:filename'
      Fog.mock!
    end

    after do
      Paperclip::Attachment.default_options[:storage] = :filesystem
    end

    let :asset do
      Asset.make file: file_fixture
    end

    let :file do
      asset.file
    end

    let :new_name do
      'butterfly.jpg'
    end

    let :renamer do
      Slices::Asset::Rename::Fog.new(file, new_name)
    end

    it "stores on fog" do
      expect(Paperclip::Attachment.default_options[:storage]).to eq :fog
    end

    it "uses the Paperclip Fog directory object" do
      directory = renamer.directory
      expect(directory).to be_a Fog::Storage::AWS::Directory
    end

    it "uses Fog to rename files" do
      renamer.rename(:original)
      files = renamer.directory.files.map(&:key)
      expect(files).to include "original/#{new_name}"
    end

  end
end
