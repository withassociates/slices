class PaperclipValidator < ActiveModel::Validator
  def validate(record)
    record.errors[:file] << 'Must specify a file' unless record.file_file_name.present?
  end
end
