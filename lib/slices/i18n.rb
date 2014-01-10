require 'slices/i18n/backend'

I18n.backend = I18n::Backend::Chain.new(
  Slices::I18n::Backend.new,
  I18n.backend
)
