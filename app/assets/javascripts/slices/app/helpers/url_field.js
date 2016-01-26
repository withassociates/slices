// Creates a URL field.
//
// Example:
//
//     {{urlField field="example"}}
//
Handlebars.registerHelper('urlField', function(options) {
  var view = new slices.UrlFieldView({
    id         : slices.fieldId(this, options.hash.field),
    name       : options.hash.field,
    value      : this[options.hash.field],
    autoAttach : true
  });

  return new Handlebars.SafeString(view.placeholder());
});

