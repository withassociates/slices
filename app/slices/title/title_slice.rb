class TitleSlice < Slice
  field :title, type: String
  validates_presence_of :title
end
