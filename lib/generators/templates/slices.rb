require File.dirname(__FILE__) + '/../../slices/version'

# Remove files
remove_file "README.rdoc"
remove_file "public/index.html"
remove_file "public/404.html"
remove_file "public/422.html"
remove_file "public/500.html"
remove_file "public/favicon.ico"
remove_dir "doc"

create_file "public/favicon.ico"

file "README.md", <<-END
# #{app_const_base}

Built with [Slices](http://slices.withassociates.com).

Need help? See the [Slices wiki](https://github.com/withassociates/slices/wiki).
END

# Set up .gitignore files
remove_file ".gitignore"
file ".gitignore", <<-END
.DS_Store
*.swp
.bundle
.sass-cache
coverage
db/*.sqlite3
db/*development*
db/*production*
db/*test*
db/mongod.lock
log/*.log
public/assets
public/cache
public/system
tmp
END

# mongoid.yml
file "config/mongoid.yml", <<-END
development:
  host: localhost
  database: #{app_name}_development

test:
  host: localhost
  database: #{app_name}_test

production:
  host: localhost
  database: #{app_name}_development
END

initializer "slices.rb", <<-END
# Slices::Config.add_asset_styles(
#   slice_full_width: '945x496>',
#   avatar:           '30x30#',
# )

ActionView::Base.send(:include, AssetsHelper)

END

# Gemfile
run "rm Gemfile"
file "Gemfile", <<-END
source 'https://rubygems.org'

gem 'slices', '~> #{Slices::VERSION}'

group :assets do
  gem 'sass-rails'
  gem 'therubyracer'
  gem 'uglifier'
end

group :development do
  gem 'capistrano', require: false
  gem 'foreman', require: false
  gem 'unicorn', require: false
end

group :test do
  gem 'capybara'
  gem 'database_cleaner'
  gem 'launchy'
  gem 'rspec-rails'
end

END

# Generate example slices
generate("slice text text:text")
generate("slice images images:attachments")

# Default layout
remove_file "app/views/layouts/application.html.erb"

file "app/views/layouts/default.html.erb", <<-END
<!doctype html>
<html>
  <head>
    <%= render "shared/head" %>
  </head>
  <body class="layout-default">
    <section id="main" role="main">
      <%= container "content" %>
    </section>
  </body>
</html>
END

file "app/views/shared/_head.html.erb", <<-END
<meta charset="utf-8">
<%= csrf_meta_tags %>

<title>#{app_const_base}</title>

<!-- <meta name="description" content=""> -->

<meta name="viewport" content="width=device-width, initial-scale=1.0">

<%= stylesheet_link_tag *%w[
  application
] %>

<%= javascript_include_tag *%w[
  //cdnjs.cloudflare.com/ajax/libs/jquery/1.10.2/jquery.min.js
  application
] %>

<!--[if lt IE 9]>
<%= javascript_include_tag *%w[
  //cdnjs.cloudflare.com/ajax/libs/html5shiv/3.6.2/html5shiv.min.js
] %>
<![endif]-->

<meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1">
END

# Assets directory structure
remove_file "app/assets/images/rails.png"
create_file "app/assets/images/.gitkeep"

# Rspec
generate("rspec:install")

file ".rspec", <<-END, force: true
--colour
--format=documentation
END

file "spec/spec_helper.rb", <<-END, force: true
ENV['RAILS_ENV'] ||= 'test'

require File.expand_path '../../config/environment', __FILE__
require 'rspec/rails'
require 'rspec/autorun'

Dir[Rails.root.join('spec/support/**/*.rb')].each { |f| require f }

RSpec.configure do |config|
  config.order = 'random'

  config.before :suite do
    DatabaseCleaner.orm = 'mongoid'
    DatabaseCleaner.strategy = :truncation
  end

  config.before do
    DatabaseCleaner.start
  end

  config.after do
    DatabaseCleaner.clean
  end
end
END

# Admin nav partials
file "app/views/admin/shared/_custom_navigation.html.erb", <<-END
<%# Place custom navbar controls here i.e. %>
<%#= admin_nav_link 'Example', example_path %>
END

file "app/views/admin/shared/_custom_links.html.erb", <<-END
<%# Place custom navbar links here i.e. %>
<%#= content_tag :li, link_to('Example', example_path) %>
END

# Procfile
file "Procfile", "web: bundle exec unicorn -p $PORT"
git add: "--all"
git commit: "-m 'Add Procfile'"

# Seed the database
rake "slices:seed"

say "All done!", :green
say "Remember to run `bundle install` when you first cd into the project", :green

