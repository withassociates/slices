# Slices::Config.add_asset_styles(
#   slice_full_width: '945x496>',
#   avatar:           '30x30#',
# )

# Configure the Google Apps domain to use for quick auth.
# Press the '=' key on the admin sign-in screen to authenticate via
# a Google Apps account within the domain configured here.
# Slices::Config.google_apps_domain = 'example.com'

# Configure templates for new page fields and page actions
# Slices::Config.page_fields_template = 'slices/page_fields'
# Slices::Config.page_actions_template = 'slices/page_actions'

ActionView::Base.send(:include, AssetsHelper)
