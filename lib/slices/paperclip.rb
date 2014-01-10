Paperclip.options[:log] = true
require 'paperclip_validator'

Paperclip.interpolates :mon_year do |attachment, style|
  attachment.instance.id.generation_time.strftime("%m%Y")
end

#This is a hack used to access Paperclip's internal cache
#of attributes it reads from the attachment. Used as part
#of the file renaming code.
class Paperclip::Attachment
  attr_accessor :_file_file_name
end
