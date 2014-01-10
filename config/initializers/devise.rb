require 'omniauth/openid'
require 'openid/store/filesystem'
require 'devise/orm/mongoid'

ActiveSupport::SecureRandom = SecureRandom

Devise.setup do |config|
  config.omniauth :google_apps,
    OpenID::Store::Filesystem.new('/tmp'),
    domain: Slices::Config.google_apps_domain

  config.use_salt_as_remember_token = true
  config.mailer_sender = "hello@example.com"
end
