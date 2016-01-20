class SlideshowSlice < Slice
  include Slices::HasAttachments

  class Slide < Attachment
    field :caption, localize: Slices::Config.i18n?
    field :link
  end
  has_attachments :slides, class_name: 'SlideshowSlice::Slide'
end

