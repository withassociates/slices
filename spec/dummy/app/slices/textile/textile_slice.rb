class TextileSlice < Slice
  field :textile, type: String, localize: Slices::Config.i18n?
  validates_presence_of :textile
end
