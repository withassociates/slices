module DeviseHelpers
  def sign_in_as_admin(options = {})
    options = {
      email: 'hello@withassociates.com',
      password: '123456'
    }.merge(options)

    options[:password_confirmation] = options[:password]

    Admin.create!(options).tap do |admin|
      controller.session[:admin_id] = admin.id
    end
  end
end

RSpec.configure do |config|
  config.include DeviseHelpers, type: :controller
end

