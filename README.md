# Slices CMS

In-house CMS of [With Associates](http://withassociates.com/).

[![Circle CI](https://circleci.com/gh/withassociates/slices/tree/master.svg?style=svg)](https://circleci.com/gh/withassociates/slices/tree/master)
[![Code Climate](https://codeclimate.com/github/withassociates/slices.png)](https://codeclimate.com/github/withassociates/slices)
[![Gemnasium](https://gemnasium.com/withassociates/slices.png)](https://gemnasium.com/withassociates/slices)

## Getting Started

### Prerequisites

Slices requires [Ruby](https://ruby-lang.org), [MongoDB](http://mongodb.org),
and [ImageMagick](http://imagemagick.org).

We suggest installing Ruby using [ruby-install](https://github.com/postmodern/ruby-install):

```sh
$ ruby-install --latest ruby
```

Install MongoDB and ImageMagick with [Homebrew](http://brew.sh):

```sh
$ brew install mongodb ImageMagick  # this can take a while
```

### Generating a Slices Project

We'll need to create a Rails project:

```sh
$ gem install rails -v 3.2.22
$ rails _3.2.22_ new mywebsite -JOT
$ cd mywebsite
```

Add Slices to the project’s Gemfile:

```ruby
gem 'slices', '~> 2.0.0'
```

Run bundler:

```sh
$ bundle install
```

Run the generator and follow the instructions to configure Slices for the first time:

```sh
$ rails generate slices:install
```

At the end of this process we should have a new Slices project with a git
repository created, gems installed, database seeded and ready to run:

```sh
$ rails server
```

Visit `http://localhost:3000/admin` to begin using Slices.

### Generating Slices

The quickest way to create a Slice is to use the generator. In this example
we're going to create a Slice called `title_body` with title and body fields.

```shell
$ rails generate slice title_body title:string body:text
```

The syntax is `field_name:field_type`.

This command will create a new folder called `title_body` within `apps/slices`,
containing the required Ruby file, the Handlebars templates for the Admin view,
and the HTML for the front-end.

#### Slice Field Types

```
Field Type   | Best for               | HTML Control
-------------+------------------------+--------------------
string       | Single lines of text   | Text input
text         | Multiple lines of text | Textarea
boolean      | Settings               | Checkbox input
date         | Dates                  | Date input
datetime     | Times                  | Datetime input
attachments  | Files and images       | Attachment composer
page         | Links to other pages   | Internal link field
```

An example of a complicated Slice:

```shell
$ rails generate slice carousel title:string gallery:attachments link:page
```

## License

Slices is released under the [MIT license](http://www.opensource.org/licenses/MIT).

Copyright (c) 2016 With Associates.
