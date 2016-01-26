# Snippets

Snippets are handy for adding small pieces of editable content to your page -
for instance, in a static footer.

## Enabling Snippets

To enable Snippets, add the following to `config/initializers/slices.rb`

```ruby
Slices::Config.use_snippets!
```

## Creating a new snippet

Enter into the Rails console and create a new snippet:

```ruby
$ Snippet.create(key: 'my_snippet')
```

This will now be editable under the 'Snippets' tab of the Slices admin panel.

## Using a snippet in a layout

```erb
<%= snippet('my_snippet') %>
```
