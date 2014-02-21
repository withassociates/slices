Paperclip.options[:log] = true
require 'paperclip_validator'

Paperclip.interpolates :fingerprint_partition do |attachment, style|
  id = attachment.fingerprint
  "#{id[0..2]}/#{id[3..-1]}"
end

#This is a hack used to access Paperclip's internal cache
#of attributes it reads from the attachment. Used as part
#of the file renaming code.
class Paperclip::Attachment
  attr_accessor :_file_file_name
end
