// Creates a radio field.
//
// Example:
//
//     {{#radioField field="example"}}
//       <input type="radio" value="one">
//       <input type="radio" value="two">
//       <input type="radio" value="three">
//     {{/radioField}}
//
Handlebars.registerHelper('radioField', function(options) {
  var view = new slices.RadioFieldView({
    id         : slices.fieldId(this, options.hash.field),
    name       : options.hash.field,
    value      : this[options.hash.field],
    inner      : options.fn,
    autoAttach : true
  });

  return new Handlebars.SafeString(view.placeholder());
});
