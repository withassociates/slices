# Creating Slices

## A basic Slice

The quickest way to create a Slice is to use the generator. In this example
we're going to create a Slice called `title_body` with title and body fields.

```shell
$ rails generate slice title_body title:string body:text
```

The syntax is `field_name:field_type`.

This command will create a new folder called `title_body` within `apps/slices`,
containing the required Ruby file, the Handlebars templates for the Admin view,
and the HTML for the front-end.

## Slice Field Types

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
$ rails g slice carousel title:string gallery:attachments link:page
```
