require 'spec_helper'

describe "Authentication for /admin", type: :request, js: true do

  it "should sign in and redirect to '/admin/site_maps'" do
    Admin.create!(email: 'hello@withassociates.com', password: '123456')
    StandardTree.build_minimal

    visit '/admin'
    expect(page).to have_no_css('header li a', text: 'Log out')

    fill_in 'Email', with: 'hello@withassociates.com'
    fill_in 'Password', with: '123456'
    click_on 'Sign in'

    expect(page.current_path).to eq('/admin/site_maps')
  end

  it "should redirect to sign in page if not signed in" do
    visit '/admin/site_maps'
    expect(page.current_path).to eq(new_admin_session_path)
  end

  it "should redirect to home page after signing out" do
    sign_in_as_admin
    click_on 'Log out'
    expect(page.current_path).to eq('/')
  end

  it "should have current user info in admin bar" do
    admin = sign_in_as_admin
    expect(page).to have_css('header li a', text: 'Log out')
    expect(page).to have_css('header li a', text: 'Account')
    expect(page).to have_css('header li', text: admin.email)
  end

  it "should redirect /admin to /admin/site_maps" do
    sign_in_as_admin
    visit '/admin'
    expect(page.current_path).to eq('/admin/site_maps')
  end
end

