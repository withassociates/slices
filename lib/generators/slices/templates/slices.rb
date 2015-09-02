# Slices::Config.add_asset_styles(
#   slice_full_width: '945x496>',
#   avatar:           '30x30#',
# )

# Configure templates for new page fields and page actions
# Slices::Config.page_fields_template = 'slices/page_fields'
# Slices::Config.page_actions_template = 'slices/page_actions'

ActionView::Base.send(:include, AssetsHelper)
