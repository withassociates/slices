class SlideshowSlice < Slice
  include Slices::HasAttachments

  class Slide < Attachment
    field :caption
    field :link
  end
  has_attachments :slides, class_name: 'SlideshowSlice::Slide'

end

