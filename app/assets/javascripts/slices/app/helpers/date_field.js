// Creates a date field.
//
// Example:
//
//     {{dateField field="example"}}
//
Handlebars.registerHelper('dateField', function(options) {
  var view = new slices.DateFieldView({
    id         : slices.fieldId(this, options.hash.field),
    name       : options.hash.field,
    value      : this[options.hash.field],
    autoAttach : true
  });

  return new Handlebars.SafeString(view.placeholder());
});
