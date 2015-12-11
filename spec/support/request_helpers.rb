module RequestHelpers

  def jqtrigger(element, action)
    page.execute_script "$(\"#{element}\").#{action.to_s}();"
  end

  def asset_fixture_path(file)
    File.join(Rails.root, 'spec', 'fixtures', file)
  end

  def asset_fixture(file='test.jpg')
    File.new(asset_fixture_path(file), 'r')
  end

  def sign_in_as_admin(super_user = false)
    email = 'hello@withassociates.com'
    password = '123456'
    admin = Admin.create!(
      email: email,
      password: password,
    )
    admin.super_user = super_user
    admin.save
    StandardTree.build_minimal if Page.count == 0

    visit '/admin/sign_in'
    fill_in 'Email', with: email
    fill_in 'Password', with: password
    click_on 'Sign in'
    admin
  end

  def sign_in_as_super
    sign_in_as_admin(true)
  end

  def auto_confirm_with value
    page.execute_script <<-JS
      window.confirm = function() { return #{value} }
    JS
  end

  def js_click_on selector, options = {}
    event_options = {
      which: 1,
      shiftKey: options[:shift_key] == true
    }.to_json.gsub(/"(.+?)":/, '\1:')

    page.execute_script <<-JS
      $('#{selector}').trigger($.Event('mousedown', #{event_options}));
      $('#{selector}').trigger($.Event('mouseup', #{event_options}));
      $('#{selector}').trigger($.Event('click', #{event_options}));
    JS
  end

  def capture_js_confirm
    page.evaluate_script 'window.confirmation = null'
    page.evaluate_script 'window.confirm = function(message) { window.confirmation = message; return true; }'
    yield
    page.evaluate_script 'window.confirmation'
  end

  def js_keydown keycode
    page.execute_script <<-JS
      $(window).trigger($.Event('keydown', { which: #{keycode} }));
    JS
  end

  def create_asset_fixtures
    Asset.make file: file_fixture
    Asset.make file: file_fixture('pepper-pot.jpg')
  end

  def wait_for_ajax
    Timeout.timeout(Capybara.default_max_wait_time) do
      loop until finished_all_ajax_requests?
    end
  end

  def finished_all_ajax_requests?
    page.evaluate_script('jQuery.active').zero?
  end
end
