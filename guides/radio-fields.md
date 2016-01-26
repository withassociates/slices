# Radio Fields

To use radio fields, follow this formula...

Let's say we've a field on the slice called 'color'.
This is how we'd structure the radio buttons:

```html
<ul id="slices-{{id}}-color" data-value="{{color}}">
  <li>
    <input type="radio" value="red"
           id="option-{{id}}-red" name="slices-{{id}}-color">
    <label for="option-{{id}}-red">Red</label>
  </li>
  <li>
    <input type="radio" value="green"
           id="option-{{id}}-green" name="slices-{{id}}-color">
    <label for="option-{{id}}-green">Green</label>
  </li>
  <li>
    <input type="radio" value="blue"
           id="option-{{id}}-blue" name="slices-{{id}}-color">
    <label for="option-{{id}}-blue">Blue</label>
  </li>
</ul>
```

The important points to note:

- The field id `slices-{{id}}-color` goes on the common parent.
- The value `data-value="{{color}}"` also goes on the common parent.
- The name attribute of the radio buttons is the field id (see above).
- To relate labels to inputs, use `option-{{id}}-value` in `for` and `id`.
