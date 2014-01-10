# This module provides methods for rendering HTML that links views to assets.
#
#   image_if_present(slice.image, :medium)
#   # => <img alt="image" height="146" src="/system/50ca095/medium/image.jpg" width="220" />
#
module AssetsHelper

  # Returns an image tag for image of the specified size. If the image is nil or
  # not present then nothing is returned. The image can be an Asset or
  # Attachment. The available sizes are defined by {Slices::Config.asset_styles}.
  # The image tag will have width and height attributes.
  #
  #   image_if_present(slice.image, :medium)
  #   # => <img alt="image" height="146" src="/system/50ca095/medium/image.jpg" width="220" />
  #
  # @param [Asset, Attachment]  image         Asset or Attachemnt
  # @param [Symbol]             size          Size of image
  # @param [Hash]               options       Optional options for the Rails image_tag
  # @return [String]                          Image tag
  #
  def image_if_present(image, size, options = {})
    if image.respond_to?(:asset)
      image = image.asset
    end

    size = size.to_sym
    if image.present? && Slices::Config.asset_styles.has_key?(size)
      options.reverse_merge!(size: image.dimensions_for(size))
      image_tag(image.url_for(size), options)
    end
  end

  # Returns a link to an image of the specificed size. If the image is nil or not
  # present then nothing is returned, and if the link is not present then only
  # the image is returned. The image can be an {Asset} or {Attachment}. The sizes
  # are defined by {Slices::Config.asset_styles}
  #
  #   link_image_if_linkable(article.path, article.feature_image, :icon)
  #   # => <a href="/article">
  #   # =>   <img alt="image" height="146" src="/system/50ca095/icon/image.jpg" width="220" />
  #   # => </a>
  #
  # @param [Object]             link          Link to pass to link_to
  # @param [Asset, Attachment]  image         Asset or Attachemnt
  # @param [Symbol]             size          Size of image
  # @param [Hash]               options       Options for the Rails image_tag,
  #                                           use +:image_options+ to pass
  #                                           options to the image_tag
  # @return [String]                          Image wrapped with a link tag
  #
  def link_image_if_linkable(link, image, size, options = {})
    image_options = options.has_key?(:image_options) ? options.delete(:image_options) : {}
    image = image_if_present(image, size, image_options)
    if image.present?
      if link.present?
        link_to(image, link, options)
      else
        image
      end
    end
  end

end

