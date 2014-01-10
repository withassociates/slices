class PreparedSlice < Slice
  attr_reader :prepared

  def prepare(params)
    @prepared = true
  end
end
