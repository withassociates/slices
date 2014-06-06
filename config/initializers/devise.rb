require 'devise/orm/mongoid'

ActiveSupport::SecureRandom = SecureRandom

Devise.setup do |config|
  config.mailer_sender = "hello@example.com"
end
