class Slice
  include Mongoid::Document
  include Slices::PositionHelper

  field :container
  field :position, type: Integer, default: 999

  class_attribute :restricted
  embedded_in :normal_page, class_name: 'Page', inverse_of: :slices
  embedded_in :set_page, inverse_of: :set_slices

  attr_accessor :renderer, :current_page
  alias :page :current_page

  def self.restricted_slice
    self.restricted = true
  end

  def self.restricted?
    self.restricted == true
  end

  def setup(options)
    self.renderer = options[:renderer]
    self.current_page = options[:current_page]
  end

  def prepare(params)
  end

  def render
    renderer.render_to_string(template_path, locals: {
      slice: self
    })
  end

  def normal_or_set_page
    normal_page || set_page
  end

  def template_path
    template = (type =~ /_(set|show)$/) ? $1 : 'show'
    File.join type.sub(/_show$/, '_set'), 'views', template
  end

  def type
    _type.to_s.underscore.gsub(/_slice$/, '')
  end

  def reference
    [_type, id].join(':')
  end

  # Print out the cache key. This will use the updated_at time of the
  # page which this document is embedded in.
  #
  # This is usually called inside a cache() block
  #
  # @example Returns the cache key
  #   document.cache_key
  #
  # @return [ String ] the string with updated_at
  def cache_key
    if time = normal_or_set_page.try(:updated_at)
      "#{model_key}/#{id}-#{time.to_s(:number)}"
    else
      super
    end
  end

  def client_id?
    attributes.include?('client_id')
  end

  def id_or_client_id
    client_id? ? client_id : id
  end

  def to_delete?
    attributes.include?('_deleted')
  end

  def write_attributes(attrs)
    attrs = attrs.symbolize_keys
    self.embedded_relations.each do |field, metadata|
      field = field.to_sym
      next unless attrs.has_key?(field)

      attrs[field] = (attrs[field] || []).map do |embedded_attrs|
        if embedded_attrs[:_id].present?
          embedded_doc = send(field).find(embedded_attrs[:_id])
          embedded_doc.write_attributes(embedded_attrs)
          embedded_doc
        else
          metadata.class_name.constantize.new(embedded_attrs)
        end
      end
    end

    super
  end

  def as_json(*args)
    attributes.symbolize_keys.except(:_id, :_type).tap do |result|
      result.merge!(id: id, type: type)
      result.merge!(client_id: client_id) if client_id? && new_record?

      self.embedded_relations.each do |field, metadata|
        result.merge!(field.to_sym => send(field).map(&:as_json))
      end
    end
  end

  def search_text
    text_fields = fields.values.select do |field|
      (field.type == String) && (field.name !~ /^container$|_id$/)
    end
    text_fields.map { |field| self[field.name.to_sym] }.join(" ")
  end
end
