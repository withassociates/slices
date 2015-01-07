module Slices
  module LocalizedFields
    def localized_field_names
      fields.select { |name, field| field.localized? }.map do |name, field|
        name.to_sym
      end
    end
  end
end
