require 'capybara/poltergeist'

module Capybara::Poltergeist
  class Client
    private

    def redirect_stdout
      prev = STDOUT.dup
      prev.autoclose = false
      $stdout = @write_io
      STDOUT.reopen(@write_io)

      prev = STDERR.dup
      prev.autoclose = false
      $stderr = @write_io
      STDERR.reopen(@write_io)
      yield
    ensure
      STDOUT.reopen(prev)
      $stdout = STDOUT
      STDERR.reopen(prev)
      $stderr = STDERR
    end
  end
end

class WarningSuppressor
  def self.write(message)
    messages = ['QFont::setPixelSize: Pixel size <= 0', 'CoreText performance note:', 'Method userSpaceScaleFactor']
    messages.each do |m|
      return 0 if message =~ m
    end
    puts message
  end
end

Capybara.register_driver :poltergeist do |app|
  Capybara::Poltergeist::Driver.new(app, {
    phantomjs_logger: WarningSuppressor,
    debug: false,
    inspector: true
  })
end

module Capybara::Node::Matchers

  def enabled?
    self[:disabled].nil?
  end

  def disabled?
    !enabled?
  end

end

Capybara.javascript_driver = :poltergeist

