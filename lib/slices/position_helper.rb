module Slices
  module PositionHelper

    # Returns an array of slices in the same container, including self.
    #
    # @return [Array]
    #
    def peers
      @peers ||= normal_or_set_page.ordered_slices.select do |slice|
        slice.container == self.container
      end
    end

    # Returns the previous slice in the container, or +nil+ if this is the
    # first slice.
    #
    # @return [Slice]
    #
    def previous_slice
      index = peers.index(self) - 1
      index < 0 ? nil : peers[index]
    end

    # Returns the next slice in the container, or +nil+ if this is the
    # last slice.
    #
    # @return [Slice]
    #
    def next_slice
      peers[peers.index(self) + 1]
    end

    # Is this the first slice in the container?
    #
    def first_in_container?
      self == peers.first
    end

    # Is the previous slice of the same type?
    #
    def first_adjacent_of_type?
      previous_slice.try(:class) != self.class
    end

    # Is this the last slice in the container?
    #
    def last_in_container?
      self == peers.last
    end

    # Is the next slice the same type?
    #
    def last_adjacent_of_type?
      next_slice.try(:class) != self.class
    end

    # Is this the only slice in the container?
    #
    def alone_in_container?
      peers.size == 1
    end

    # Are both the next and previous slices different types?
    #
    def alone_in_adjacent_of_type?
      first_adjacent_of_type? && last_adjacent_of_type?
    end

    # The position of the slice in the container, the first slice has a position
    # of 1
    #
    # @return [Integer]
    #
    def position_in_container
      peers.index(self) + 1
    end

    # The position of the slice in a group of the same slices
    #
    # For example, given the following slices
    #   [TitleSlice, CopySlice, CopySlice, CopySlice]
    #
    # The second +CopySlice+ would have a +position_in_adjacent_of_type+ of 2
    #
    # @return [Integer]
    #
    def position_in_adjacent_of_type
      slices = []
      reversed = peers.reverse
      reversed[reversed.index(self)..-1].each do |slice|
        break unless slice.class == self.class
        slices << slice
      end
      slices.length
    end
  end

end
