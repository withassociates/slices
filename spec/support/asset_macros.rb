module AssetMacros

  def use_extended_style
    before(:all) do
      @orginal_styles = Asset.attachment_definitions[:file][:styles]
      Asset.attachment_definitions[:file][:styles][:extended] = '80x60>'
    end

    after(:all) do
      Asset.attachment_definitions[:file][:styles] = @orginal_styles
    end
  end

end

