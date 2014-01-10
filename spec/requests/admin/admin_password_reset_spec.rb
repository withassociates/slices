require 'spec_helper'

describe "Password reset for /admin", js: true do

  it "Reset admin users password" do
    Devise::Mailer.default_url_options[:host] = "example.com"
    Admin.create!(email: 'hello@withassociates.com', password: '123456')
    StandardTree.build_minimal

    visit '/admin/sign_in'
    page.should have_no_css('header li a', value: 'Log out')

    click_on 'Forgot your password?'

    fill_in 'Email', with: 'hello@withassociates.com'
    click_on 'Send me reset password instructions'

    email = ActionMailer::Base.deliveries.last
    url = email.body.to_s[/example\.com(.*)\"/, 1]
    sleep 0.2
    visit url

    fill_in 'New password', with: 'hello12'
    fill_in 'Confirm new password', with: 'hello12'
    click_on 'Change my password'

    page.current_path.should == '/admin/site_maps'
  end

end

