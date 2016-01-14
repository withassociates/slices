# Internal Link Helper

If you want to provide a field that auto-completes internal links, using the
following helper:

e.g. `app/slices/example/templates/example.hbs`:

```html
<li>
  <label for="slices-{{id}}-url">URL:</label>
  <input
    type="text"
    id="slices-{{id}}-url"
    value="{{url}}"
    data-plugin="livefield"
    data-store="/admin/pages/search.json?query=:query"
    data-template="#livefield-result-template"
  >
</li>
```

For more info, see the [Livefield.js Repo](https://github.com/withassociates/livefield.js).

## Room For Improvement

This helper could do with its own handlebars helper method, in line with our
other field helpers. Something along the lines of `{{urlField field="url"}}`.
