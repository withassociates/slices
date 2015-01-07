class TextileSlice < Slice
  field :textile, type: String, localize: true
  validates_presence_of :textile
end
