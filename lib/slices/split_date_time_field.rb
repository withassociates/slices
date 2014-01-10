module Slices #:nodoc:
  module SplitDateTimeField #:nodoc:
    extend ActiveSupport::Concern #:nodoc:

    module ClassMethods #:nodoc:

      def split_date_time_field(name)
        raise Error, 'Split date time is depreciated use dateField instead'
      end

    end
  end
end

