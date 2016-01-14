# Getting Started

## Prerequisites

Slices requires [Ruby](https://ruby-lang.org), [MongoDB](http://mongodb.org),
and [ImageMagick](http://imagemagick.org).

We suggest installing Ruby using [ruby-install](https://github.com/postmodern/ruby-install).

```sh
$ ruby-install --latest ruby
```

Install MongoDB and ImageMagick with [Homebrew](http://brew.sh):

```sh
$ brew install mongodb ImageMagick  # this can take a while
```

## Generating a Slices Project

We'll need to create a Rails project:

```sh
$ gem install rails -v 3.2.22
$ rails _3.2.22_ new mywebsite -JOT
$ cd mywebsite
```

Then, install the Slices gem. Add this line to your Gemfile:

```ruby
gem 'slices', '~> 2.0.0'
```

```sh
$ bundle install
```

Run this command to install Slices, and follow the instructions:

```sh
$ rails generate slices:install
```

At the end of this process we should have a new Slices project with a git
repository created, gems installed, database seeded and ready to run:

```sh
$ cd ~/Projects/mywebsite
$ rails server
```

Visit `http://localhost:3000/admin` to begin using Slices.

The next step is to create some [slices](creating-slices.md).
