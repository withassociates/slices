# Slice Preview Helper

To change the text that is displayed when this slice is minimised, use the
`slicePreview` helper at the bottom of the template, as detailed below.

The method is scoped to the slice so you can easily access any contained elements.

e.g. `app/slices/example/templates/example.hbs`:

```html
<li>
  <label for="slices-{{id}}-example">Example</label>
  <textarea id="slices-{{id}}-example">{{example}}</textarea>
</li>

{{#slicePreview}}
  // This preview would strip out any HTML tags.
  return $('<div />').html(this.find('textarea').val()).text();
{{/slicePreview}}
```
