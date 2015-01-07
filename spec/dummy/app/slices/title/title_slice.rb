class TitleSlice < Slice
  field :title, type: String, localize: Slices::Config.i18n?
  validates_presence_of :title
end
