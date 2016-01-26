// Applys default values to the context.
//
// Example:
//
//     {{applyDefaults title="Hello world" text="Lorem ipsum dolor sit amet"}}
//
Handlebars.registerHelper('applyDefaults', function(options) {
  _.defaults(this, options.hash);
});
