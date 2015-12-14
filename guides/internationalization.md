# Internationalization

Slices supports Internationalization (I18n) as of version 2 through the [Rails I18n API](http://guides.rubyonrails.org/i18n.html).
The first step is to read and follow the [Rails I18n Guide](http://guides.rubyonrails.org/i18n.html).


## Localizing a slice

Firstly add `localize: true` to all text fields which need localizing, make sure you add a
default value as there is a [bug in Mongoid](https://jira.mongodb.org/browse/MONGOID-4054)
which means the value may not be set correctly.

```ruby
class TextSlice < Slice
  field :text, type: String, localize: true, default: ''
end
```

Next add `class="i18n"` to the admin template to indicate the field is localizable.

```hbs
<li>
  <textarea id="slices-{{id}}-text" class="i18n" placeholder="Text…" rows="10">{{text}}</textarea>
</li>
```

Then render the field as normal.

 ```rhtml
<div class="slice text">
  <%= slice.text %>
</div>
```

## Localizing an existing site

Here is [Gist](https://gist.github.com/erino/eb4e1766f3203c58d0d3) with code to migrate page and slice data.

