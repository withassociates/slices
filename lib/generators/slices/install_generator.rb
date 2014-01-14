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
      mongoid_option = ask("Do you require a mongoid.yml file? (y/n)")
      if mongoid_option == "y"
        copy_file "mongoid.yml", "config/mongoid.yml"
      end
    end

    def create_procfile
      create_file "Procfile", "web: bundle exec unicorn -p $PORT"
    end

    def add_unicorn_and_foreman_gems
      append_file "Gemfile", "group :development do
  gem 'foreman', require: false
  gem 'unicorn', require: false
end"
    end

    def create_initializer
      copy_file "slices.rb", "config/initializers/slices.rb"
    end

    def create_application_layout
      copy_file "application.html.erb", "app/views/layouts/application.html.erb"
    end

    def add_to_readme
      create_file "README.md", "Built with [Slices](http://slices.withassociates.com)."
    end

    def finishing_up
      say ""
      say "---------------------------", :green
      say "All done!", :green
      say "---------------------------", :green
      say ""
      say "Run 'foreman start' and visit http://localhost:5000/admin to begin using Slices."
      say "The next step is to create some slices. You can find the guides in the wiki:"
      say "https://github.com/withassociates/slices/wiki"
      say ""
    end
  end
end
