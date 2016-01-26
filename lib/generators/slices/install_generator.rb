require 'rails/generators'
require 'thor'

module Slices
  class InstallGenerator < ::Rails::Generators::Base
    source_root File.expand_path('../templates', __FILE__)
    class_option :heroku, type: :boolean, default: false, desc: "Configure Slices for easy Heroku deployment."
    include Thor::Actions

    desc "This generator installs Slices within a Rails app."

    def create_slices_dir
      say "Running the Slices installer..."
      create_file "app/slices/.gitkeep"
    end

    def create_initializer
      copy_file "slices.rb", "config/initializers/slices.rb"
    end

    def create_application_layout
      copy_file "application.html.erb", "app/views/layouts/default.html.erb"
    end

    def create_admin_nav_partials
      create_file "app/views/admin/shared/_custom_navigation.html.erb", <<-END
      <%# Place custom navbar controls here i.e. %>
      <%#= admin_nav_link 'Example', example_path %>
      END

      create_file "app/views/admin/shared/_custom_links.html.erb", <<-END
      <%# Place custom navbar links here i.e. %>
      <%#= content_tag :li, link_to('Example', example_path) %>
      END
    end

    def optionally_create_mongoid_yaml
      generate 'mongoid:config'
    end

    def delete_superfluous_files
      remove_file "public/index.html"
      remove_file "public/rails.png"
      remove_dir "public/assets"
    end

    def heroku_options
      if options.heroku?
        say "Installing Slices for Heroku", :green
        inject_into_file "#{Rails.root}/config/application.rb", "config.assets.initialize_on_precompile = false",
          :after => "config.assets.enabled = true\n"

        gsub_file "#{Rails.root}/config/environments/production.rb",
          "config.assets.compile = false",
          "config.assets.compile = true"
      end
    end

    def finishing_up
      say ""
      say "---------------------------", :green
      say "All done!", :green
      say "---------------------------", :green
      say ""
      say "Next, run 'rake slices:seed' to create your Slices admin user and home page."
      say "Then you can run 'rails server' and visit http://localhost:3000/admin to begin using Slices."
      say "The next step is to create some slices. You can find the guides in the wiki:"
      say "https://github.com/withassociates/slices/wiki"
      say ""
    end
  end
end
