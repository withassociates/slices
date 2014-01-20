# Slices CMS

In-house CMS of [With Associates](http://withassociates.com/).

## Starting a new Slices project

Slices requires Ruby, MongoDB and ImageMagick. If you don't have them installed, follow this [guide](https://github.com/withassociates/slices/wiki/Installation.md) before beginning.

Now we're ready to create the Slices project:

    $ cd ~/Projects
    $ rails _3.2.16_ new mywebsite -O
    $ cd ~/Projects/mywebsite

Add 'slices' to the Gemfile of your new project:

    gem 'slices'

Run `rails generate slices:install` in the terminal and follow the instructions.

If you intend to deploy your Slices app to Heroku, run `rails generate slices:install --heroku` to make life easier.

You're ready to go! Run `rails server` and visit http://localhost:3000/admin to begin using Slices.

The next step is to create some [slices](https://github.com/withassociates/slices/wiki/Creating-Slices) - there are more guides in the [Wiki](https://github.com/withassociates/slices/wiki).

## Code Status

[![Travis CI   ](https://api.travis-ci.org/withassociates/slices.png)       ](https://travis-ci.org/withassociates/slices)
[![Code Climate](https://codeclimate.com/github/withassociates/slices.png)  ](https://codeclimate.com/github/withassociates/slices)
[![Gemnasium   ](https://gemnasium.com/withassociates/slices.png)           ](https://gemnasium.com/withassociates/slices)

## License

Slices is released under the [MIT license](http://www.opensource.org/licenses/MIT). Copyright (c) 2014 With Associates.

