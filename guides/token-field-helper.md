# Token Field Helper

Token fields are useful for managing data such as tags and categories. By
default, they send back an array of values. To place one in a Slice, or in Page
meta fields, use the helper as follows:

```ruby
class MyPage < Page
  field :categories, type: Array
end
```

```html
<li>
  {{tokenField field="categories"}}
</li>
```

## Providing Options

If you'd like to provide pre-defined options for the user, you’ll need to
expose those on your model and then tell your tokenField where to look.

*NB: Token field only knows how to deal with arrays of simple strings. Be sure
to map your options into strings that can be converted back into the
appropriate type server-side.*

```ruby
class MyPage < Page
  field :categories, type: Array

  def self.available_categories
    MyPage.all.distinct :categories
  end

  def as_json options = {}
    super(options).merge available_categories: MyPage.available_categories
  end
end
```

```html
<li>
  {{tokenField field="categories" options="available_categories"}}
</li>
```

## Singular Token Fields

If your field is only intended to store a single string, you can set the
`singular` option. In this mode, tokenField will only allow one value, and will
send back a single string rather than an array.

```ruby
class MyPage < Page
  field :author, type: String

  def self.available_authors
    all.distinct :author
  end

  def as_json options = {}
    super(options).merge available_authors: MyPage.available_authors
  end
end
```

```html
<li>
  {{tokenField field="author" singular="true" options="available_authors"}}
</li>
```
