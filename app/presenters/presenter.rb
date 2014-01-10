class Presenter
  include ActionView::Helpers::TextHelper

  attr_reader :source

  def initialize(source)
    @source = source
  end
end
