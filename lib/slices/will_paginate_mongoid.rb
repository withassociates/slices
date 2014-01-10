# Due to a bit of dependency-hell, we can't include will_paginate_mongoid
# in the gemspec, so this is just the content of that Gem.

require 'mongoid'
require 'will_paginate'

unless defined? WillPaginateMongoid
  module WillPaginateMongoid
    DEFAULT_PER_PAGE = 10

    module MongoidPaginator
      extend ActiveSupport::Concern

      included do
        def self.paginate(options = {})
          options = base_options options
          page = options[:page].to_i
          per_page = options[:per_page].to_i
          offset = options[:offset].to_i

          WillPaginate::Collection.create(page, per_page) do |pager|
            fill_pager_with self.skip(offset).limit(per_page), self.count, pager
          end
        end

        private

        def self.base_options(options)
          options[:page] ||= 1
          options[:per_page] ||= 10
          options[:offset] = (options[:page].to_i - 1) * options[:per_page].to_i
          options
        end

        def self.fill_pager_with(medias, size, pager)
          pager.replace medias.to_a
          pager.total_entries = size
        end
      end
    end
  end

  ::Mongoid::Document.send :include, WillPaginateMongoid::MongoidPaginator
  ::Mongoid::Criteria.send :include, WillPaginateMongoid::MongoidPaginator
end
