class TitleSlice < Slice
  field :title, type: String, localize: true
  validates_presence_of :title
end
