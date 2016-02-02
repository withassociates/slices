module Slices
  MONGOID_OBJECT_ID = case
                      when defined?(BSON::ObjectId)
                        BSON::ObjectId
                      when defined?(Moped::BSON::ObjectId)
                        Moped::BSON::ObjectId
                      else
                        raise "Cannot identify ObjectId constant"
                      end

  module Serialization
    def self.for_json(obj)
      case obj
      when Mongoid::Document
        mongoid_document_for_json(obj)
      when MONGOID_OBJECT_ID
        bson_object_id_for_json(obj)
      when Array, Mongoid::Relations::Proxy
        array_for_json(obj)
      when Hash
        hash_for_json(obj)
      else
        obj.as_json
      end
    end

    def self.array_for_json(obj)
      obj.map { |member| for_json(member) }
    end

    def self.hash_for_json(obj)
      obj.each_with_object({}) do |(key, value), result|
        result[key.to_s] = for_json(value)
      end
    end

    def self.mongoid_document_for_json(obj)
      fields = obj.fields.merge(obj.embedded_relations)

      fields.each_with_object({}) do |(key, meta), result|
        key = normalize_key(key)
        next unless obj.respond_to?(key)
        value = obj.public_send(key)
        result[key] = for_json(value)
      end
    end

    def self.bson_object_id_for_json(obj)
      obj.to_s
    end

    def self.normalize_key(key)
      key.to_s.sub(/\A_/, "")
    end
  end
end
