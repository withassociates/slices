require 'highline/import'

module Slices
  module Tasks
    class Exists < RuntimeError; end

    def self.with_message(text)
      print "#{text} ... "
      yield
      puts "ok"
    rescue Exists
      puts "(exists)"
    end

    def self.make_virtual(role, name, status)
      with_message("Creating #{status} page") do
        if Page.where(role: role).count > 0
          raise Exists
        end
        Page.make(role: role, name: name, active: true)
      end
    end

    def self.make_home
      with_message("Creating home page") do
        raise Exists if Page.where(path: '/').any?
        Page.make(name:         'Home',
                  permalink:    '',
                  show_in_nav:  true,
                  active:       true)
      end
    end

    def self.make_errors
      make_virtual('not_found', 'Page not found', 404)
      make_virtual('error', 'Whoops', 500)
    end

    def self.make_admin
      if Admin.exists?
        say "Creating admin user ... (exists)"
        return
      end

      say("Creating admin user ...")

      admin = Admin.create!(
        name: ask('Enter a name: '),
        email: ask('Enter an email address: '),
        password: ask('Enter a password: ') { |q| q.echo = false }
      )
      admin.super_user = true
      admin.save!

      say("... ok")
    end

    def self.make_all
      make_home
      make_errors
      make_admin
    end
  end
end

namespace :slices do
  namespace :seed do
    task :foo do
      puts "Bar"
    end

    desc "Create the home page"
    task :home => :environment do
      Slices::Tasks.make_home
    end

    desc "Create 404 and 500 pages"
    task :errors => :home do
      Slices::Tasks.make_errors
    end

    desc "Create admin user"
    task :admin => :environment do
      Slices::Tasks.make_admin
    end
  end

  desc "Seed home, errors and admin user"
  task :seed => :environment do
    Slices::Tasks.make_all
  end
end

