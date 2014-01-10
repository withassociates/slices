class HumansGenerator < Rails::Generators::Base
  source_root File.expand_path('../templates', __FILE__)

  desc "This generator creates a boilerplate humans.txt file"

  def copy_humans_txt
    copy_file 'humans.txt', 'public/humans.txt'
  end

end
