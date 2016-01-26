module Slices
  class AvailableSlices

    def self.all
      # We've memoized the slices so that we never try and load them all
      # twice. If we iterate over ObjectSpace twice (see find_all_slices)
      # we sometimes find that an incomplete set of slices objects is
      # returned on subsequent calls.
      @all ||= find_all_slices
    end

    private

    def self.find_all_slices
      slices = []

      Dir.glob(File.join(Rails.root, 'app/slices/**/*_slice.rb')).each do |path|

        slice_name = File.basename(path, '.rb')
        klass      = slice_name.camelize.constantize
        basename   = File.basename(path, '_slice.rb')
        folder     = File.basename(File.dirname(path))

        fields = {
          'name' => basename.humanize.titleize,
          'template' => File.join(folder, basename),
          'restricted' => klass.restricted?
        }

        klass.fields.each do |name, field|
          next if Slice.fields[name]
          fields[name] = field.default_val
        end

        if klass.respond_to?(:attachment_fields)
          klass.attachment_fields.each do |name|
            meta = klass.reflect_on_association(name)
            fields[name.to_s] = meta.many? ? [] : nil
          end
        end

        slices << [basename, fields]

      end

      Hash[*slices.sort.flatten]
    end
  end
end

