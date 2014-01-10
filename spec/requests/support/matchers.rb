module Capybara::Node::Matchers

  def enabled?
    self[:disabled].nil?
  end

  def disabled?
    !enabled?
  end

end
