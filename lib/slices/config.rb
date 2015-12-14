module Slices
  class Config
    S3_TEMPFILE_KEY_PREFIX = 'uploads'

    # Set the asset styles for the app, this is a hash with the keys as the
    # style names and Papcerlip resize options
    #
    #   Slices::Config.add_asset_styles(
    #     :thumbnail      => "220x146#",
    #     :full_width     => "971x440#",
    #     :feature_full   => "971x475#",
    #     :slideshow      => "723x440>",
    #   )
    #
    # @param [Hash] options
    def self.add_asset_styles(options = {})
      @asset_styles = options.merge(admin_asset_styles)
    end

    # The list of asset styles in use
    #
    # @return [Hash]
    def self.asset_styles
      @asset_styles || add_asset_styles
    end

    # Enable snippets
    def self.use_snippets!
      @snippets = true
    end

    # Does this app use snippets?
    # @return [Boolean]
    def self.snippets?
      @snippets || false
    end

    def self.i18n?
      !!(
        I18n.available_locales.many? ||
          Rails.application.config.i18n.available_locales.try(:many?)
      )
    end

    def self.s3_storage?
      Paperclip::Attachment.default_options[:storage].to_sym == :fog
    end

    # S3 credentaials taken from the papercip defaults
    #
    #   {
    #     :bucket => 'slices-demo',
    #     :access_key_id => 'access key id',
    #     :secret_access_key => 'secret access key',
    #   }
    #
    # @return Hash
    def self.s3_credentials
      default_options = Paperclip::Attachment.default_options
      {
        bucket: default_options[:fog_directory],
        access_key_id: default_options[:fog_credentials][:aws_access_key_id],
        secret_access_key: default_options[:fog_credentials][:aws_secret_access_key],
      }
    end

    # Page fields template path.
    #
    # @return [String] the path
    def self.page_fields_template
      @page_fields_template || 'admin/pages/fields'
    end

    # Set page fields template path.
    #
    # @param [String] the path
    def self.page_fields_template=(path)
      @page_fields_template = path
    end

    # Page actions template path.
    #
    # @return [String] the path
    def self.page_actions_template
      @page_actions_template || 'admin/site_maps/page_actions'
    end

    # Set page actions template path.
    #
    # @param [String] the path
    def self.page_actions_template=(path)
      @page_actions_template = path
    end

    private
    def self.admin_asset_styles
      { admin: '180x180#' }
    end

    # Addition Paperclip convert options which are applied to all styles.
    # This removes colour profiles, sets the dpi to 72 dpi (the image is not
    # resampled). The colour depth is set to 8 bits per pixel
    def self.asset_convert_options
      Hash.new.tap do |options|
        asset_styles.keys.each do |style|
          next if style == :original
          options[style] = "-strip -density 72x72 -depth 8"
        end
      end
    end

  end

end
