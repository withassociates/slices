# encoding: utf-8

require 'rails/generators'
require 'thor'

module Slices
  class InstallGenerator < ::Rails::Generators::Base
    source_root File.expand_path('../templates', __FILE__)
    include Thor::Actions

    desc "This generator installs Slices within a Rails app."

    def create_slices_dir
      say "Running the Slices installer..."

      create_file "app/slices/.gitkeep"
    end

    def optionally_create_mongoid_yaml
      if ask("Do you require a mongoid.yml file? (y/n)") == "y"
        copy_file "mongoid.yml", "config/mongoid.yml"
      end
    end

    def create_application_layout
      copy_file "application.html.erb", "app/views/layouts/application.html.erb"
    end

    def finishing_up
      say("All done!")
      say("You can use a bunch of stuff. It's cool, here it is")
    end
  end
end
