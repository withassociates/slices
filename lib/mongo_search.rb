module MongoSearch
  class KeywordsExtractor
    def self.extract(text)
      if text.blank?
        []
      else
        text.mb_chars.normalize(:kd).to_s
          .gsub(/[^\x00-\x7F]/,'')
          .downcase
          .split(/[\s\.\-_]+/)
      end
    end
  end

  module Searchable
    extend ActiveSupport::Concern

    included do
      cattr_accessor :search_fields, :match
    end

    module ClassMethods
      def text_search_in(*args)
        options = args.pop if args.last.has_key?(:match)
        self.match = options[:match]
      rescue NoMethodError
      ensure
        self.match ||= :all
        self.search_fields = args

        field :_keywords, type: Array
        index :_keywords

        before_save :set_keywords
      end

      def search_in(*args)
        warn('[DEPRECATION `search_in` is deprecated. Please use `text_search_in` instead.')
        text_search_in(args)
      end

      def text_search(query)
        words = KeywordsExtractor.extract(query).map { |word| /#{word}/ }
        self.send("#{self.match}_in", _keywords: words)
      end

      def search(query)
        warn("[DEPRECATION] `search` is deprecated. Please use `text_search` instead.")
        text_search(query)
      end
    end

    private
      def set_keywords
        self._keywords = []
        search_fields.each do |field|
          if field.respond_to?(:each)
            field.each do |name, attribute|
              extract_keywords_for_association(name, attribute)
            end
          elsif respond_to?(field)
            extract_keywords(send(field))
          else
            extract_keywords(self[field])
          end
        end
        self._keywords.uniq!
      end

      def extract_keywords(text)
        self._keywords += KeywordsExtractor.extract(text) unless text.nil?
      end

      def extract_keywords_for_association(name, attribute)
        association = send(name)
        return [] if association.nil?
        if association.respond_to?(:each)
          association.each { |doc| extract_keywords(doc[attribute]) }
        else
          extract_keywords(association[attribute])
        end
      end
  end
end
