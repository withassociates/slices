// Create a composer for a given field on the model.
//
// Example:
//
//     {{#composer field="ingredients"}}
//       <input type="text"
//              name="name"
//              placeholder="Name (e.g. Cheese)..."
//              value="{{name}}">
//       <input type="text"
//              name="amount"
//              placeholder="Amount (e.g. 10kg)..."
//              value="{{amount}}">
//     {{/composer}}
//
Handlebars.registerHelper('composer', function(options) {
  var view = new slices.ComposerView({
    id         : slices.fieldId(this, options.hash.field),
    value      : this[options.hash.field],
    min        : options.hash.min,
    max        : options.hash.max,
    fields     : options.fn,
    addLabel   : options.hash.addLabel,
    autoAttach : true
  });

  return new Handlebars.SafeString(view.placeholder());
});
