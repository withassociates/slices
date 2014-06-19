RSpec::Matchers.define :be_findable do
  match do |actual|
    begin
      Page.find_by_path(actual)

      true
    rescue Page::NotFound
      false
    end
  end

  failure_message_for_should do |actual|
    "expected that '#{actual}' would be a page path"
  end

  failure_message_for_should_not do |actual|
    "expected that '#{actual}' would not be a page path"
  end
end

RSpec::Matchers.define :have_stopped_communicating do
  match do |actual|
    expect(actual).to have_no_css '#server-communication', visible: true
  end

  failure_message_for_should do |actual|
    "expected to have stopped communicating with the server"
  end

  failure_message_for_should_not do |actual|
    "expected to still be communicating with the server"
  end
end
