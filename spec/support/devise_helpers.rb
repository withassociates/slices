module DeviseHelpers
  def sign_in_as_admin(options = {})
    options = {
      email: 'hello@withassociates.com',
      password: '123456'
    }.merge(options)

    options[:password_confirmation] = options[:password]

    Admin.create!(options).tap do |admin|
      sign_in(admin)
    end
  end
end

RSpec.configure do |config|
  config.include DeviseHelpers, type: :controller
  config.include Devise::TestHelpers, type: :controller
end

