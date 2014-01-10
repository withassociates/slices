# Slices CMS

In-house CMS of [With Associates](http://withassociates.com/)

## Starting a new slices project

Follow this [guide](https://github.com/withassociates/slices/wiki/Installation.md)
first if you don't have MongoDB, ImageMagick and Ruby installed.

We'll need to checkout the slices project, install the relevant gems using
bundler and then use a Rails template to create the new project.

    $ cd ~/Projects     # or where you store git repos
    $ git clone git@github.com:withassociates/slices.git
    $ cd slices
    $ gem install bundler
    $ bundle install

Or if you have slices already installed

    $ cd ~/Projects/slices  # or where you store git repos
    $ git pull
    $ bundle install

Now we're ready to create the slices project.

    $ cd ~/Projects
    $ gem install rails -v '~> 3.2.0'
    $ rails new mywebsite -JOT -m ~/Projects/slices/lib/generators/templates/slices.rb

At the end of this process we should have a new slices project with git repository
created, gems installed, database seeded and ready to run:

    $ cd ~/Projects/mywebsite
    $ foreman start

Visit http://localhost:5000/admin to begin using Slices.

The next step is to create some [slices](https://github.com/withassociates/slices-legacy/wiki/Creating-Slices)
and theres more guides in the [wiki](https://github.com/withassociates/slices/wiki)

## Code Status

[![Travis CI   ](https://api.travis-ci.org/withassociates/slices.png)       ](https://travis-ci.org/withassociates/slices)
[![Code Climate](https://codeclimate.com/github/withassociates/slices.png)  ](https://codeclimate.com/github/withassociates/slices)
[![Gemnasium   ](https://gemnasium.com/withassociates/slices.png)           ](https://gemnasium.com/withassociates/slices)

## Copyright

Copyright (c) 2014 With Associates

