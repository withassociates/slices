// Create a token field for a given field and source on the model.
//
// Example:
//
//     {{tokenField field="categories" options="available_categories"}}
//
Handlebars.registerHelper('tokenField', function(options) {
  var view = new slices.TokenFieldView({
    id         : slices.fieldId(this, options.hash.field),
    values     : this[options.hash.field],
    options    : options.hash.options && this[options.hash.options],
    singular   : options.hash.singular === 'true',
    autoAttach : true
  });

  return new Handlebars.SafeString(view.placeholder());
});
