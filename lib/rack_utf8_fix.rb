require 'escape_utils'

module Rack
  module Utils
    def escape s
      EscapeUtils.escape_url s.to_s
    end
  end
end

