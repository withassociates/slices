require 'spec_helper'

describe Slices::Config do

  context "Configuring asset styles" do
    before do
      Slices::Config.add_asset_styles(
        extended: '705x456>',
        admin: '90x90!'
      )
    end

    let :my_class do
      my_class = Class.new(Asset) do
        include Mongoid::Paperclip
        has_mongoid_attached_file :file,
          styles: Slices::Config.asset_styles,
          convert_options: Slices::Config.asset_convert_options
      end
    end

    let :asset_styles do
      my_class.new.file.styles
    end

    let :convert_options do
      my_class.new.file.options[:convert_options]
    end

    it "keeps the existing admin style" do
      expect(asset_styles[:admin].geometry).to eq '180x180#'
    end

    it "has the new extended style" do
      expect(asset_styles[:extended].geometry).to eq '705x456>'
    end

    it "generates conversion options" do
      expect(convert_options.keys).to include :extended
    end
  end

end
