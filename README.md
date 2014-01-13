# Slices CMS

In-house CMS of [With Associates](http://withassociates.com/)

## Starting a new Slices project

Slices requires Ruby, MongoDB and ImageMagick. If you don't have them installed, follow this [guide](https://github.com/withassociates/slices/wiki/Installation.md) before beginning.

We'll need to checkout the Slices project, install the relevant gems using Bundler and use a Rails template to create the new project:

    $ cd ~/Projects     # or wherever you store git repositories
    $ git clone git@github.com:withassociates/slices.git
    $ cd slices
    $ gem install bundler
    $ bundle install

Or if you have Slices already installed:

    $ cd ~/Projects/slices  # or wherever you store git repositories
    $ git pull
    $ bundle install

Now we're ready to create the Slices project:

    $ cd ~/Projects
    $ gem install rails -v '~> 3.2.0'
    $ rails new mywebsite -JOT -m ~/Projects/slices/lib/generators/templates/slices.rb
    
Or, if you have later versions of Rails installed, specify 3.2.0 with this command:

    $ cd ~/Projects
    $ rails _3.2.0_ new mywebsite -JOT -m ~/Projects/slices/lib/generators/templates/slices.rb

At the end of this process we should have a new Slices project with a git repository created, gems installed, database seeded and ready to run:

    $ cd ~/Projects/mywebsite
    $ foreman start

Visit http://localhost:5000/admin to begin using Slices.

The next step is to create some [slices](https://github.com/withassociates/slices/wiki/Creating-Slices) - there are more guides in the [Wiki](https://github.com/withassociates/slices/wiki).

## Code Status

[![Travis CI   ](https://api.travis-ci.org/withassociates/slices.png)       ](https://travis-ci.org/withassociates/slices)
[![Code Climate](https://codeclimate.com/github/withassociates/slices.png)  ](https://codeclimate.com/github/withassociates/slices)
[![Gemnasium   ](https://gemnasium.com/withassociates/slices.png)           ](https://gemnasium.com/withassociates/slices)

## License

Slices is released under the [MIT license](http://www.opensource.org/licenses/MIT). Copyright (c) 2014 With Associates.

