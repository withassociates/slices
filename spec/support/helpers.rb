module RequestHelpers
  def click_on_save_changes
    click_on 'Save changes'
    page.should have_stopped_communicating
  end

  def hover_over_asset_thumb selector = '.asset-library-item:first'
    page.execute_script "$('#{selector} dl').css({ visibility: 'visible' })"
  end
end

RSpec.configure do |config|
  config.include RequestHelpers, js: true
end
