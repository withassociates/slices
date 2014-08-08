class TextileSlice < Slice
  field :textile, type: String
  validates_presence_of :textile
end
