shared_context "signed in as admin" do

  let! :admin do
    Admin.create! email: 'hello@withassociates.com',
                  password: '123456'
  end

  before type: :request do
    visit new_admin_session_path
    fill_in 'Email', with: admin.email
    fill_in 'Password', with: admin.password
    click_on 'Sign in'
  end

  before type: :api do
    post admin_session_path admin: { email: admin.email, password: admin.password }
  end

end

