require 'spec_helper'

describe "Authentication for /admin", js: true do

  it "should sign in and redirect to '/admin/site_maps'" do
    Admin.create!(email: 'hello@withassociates.com', password: '123456')
    StandardTree.build_minimal

    visit '/admin/sign_in'
    page.should have_no_css('header li a', value: 'Log out')

    fill_in 'Email', with: 'hello@withassociates.com'
    fill_in 'Password', with: '123456'
    click_on 'Sign in'

    page.current_path.should == '/admin/site_maps'
  end

  it "should redirect to sign in page if not signed in" do
    visit '/admin/site_maps'
    page.current_path.should == '/admin/sign_in'
  end

  it "should redirect to home page after signing out" do
    sign_in_as_admin
    click_on 'Log out'
    page.current_path.should == '/'
  end

  it "should have current user info in admin bar" do
    admin = sign_in_as_admin
    page.should have_css('header li a', value: 'Log out')
    page.should have_css('header li a', value: 'Account')
    page.should have_css('header li', value: admin.email)
  end

  it "should redirect /admin to /admin/site_maps" do
    sign_in_as_admin
    visit '/admin'
    page.current_path.should == '/admin/site_maps'
  end
end

