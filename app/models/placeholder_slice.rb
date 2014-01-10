class PlaceholderSlice < Slice
  restricted_slice

  def render
    renderer.render_container(self.container, current_page.ordered_slices)
  end
end

