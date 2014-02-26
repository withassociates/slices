require 'devise/orm/mongoid'
require 'omniauth-google-apps'

ActiveSupport::SecureRandom = SecureRandom

Devise.setup do |config|
  config.mailer_sender = "hello@example.com"
  if Slices::Config.google_apps_domain
    config.omniauth :google_apps, domain: Slices::Config.google_apps_domain
  end
end
