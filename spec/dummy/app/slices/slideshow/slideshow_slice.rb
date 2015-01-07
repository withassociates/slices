class SlideshowSlice < Slice
  include Slices::HasAttachments

  class Slide < Attachment
    field :caption, localize: true
    field :link
  end
  has_attachments :slides, class_name: 'SlideshowSlice::Slide'

end

