require 'spec_helper'

describe "Password reset for /admin", type: :request, js: true do

  it "Reset admin users password" do
    pending

    Devise::Mailer.default_url_options[:host] = "example.com"
    Admin.create!(email: 'hello@withassociates.com', password: '123456')
    StandardTree.build_minimal

    visit new_admin_session_path
    expect(page).to have_no_css('header li a', text: 'Log out')

    click_on 'Forgot your password?'

    fill_in 'Email', with: 'hello@withassociates.com'
    click_on 'Send me reset password instructions'

    email = ActionMailer::Base.deliveries.last
    url = email.body.to_s[/example\.com(.*)\"/, 1]
    wait_for_ajax
    visit url

    fill_in 'New password', with: 'hello12'
    fill_in 'Confirm new password', with: 'hello12'
    click_on 'Change my password'

    expect(page.current_path).to eq('/admin/site_maps')
  end

end

