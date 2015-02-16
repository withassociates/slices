Handlebars.registerHelper('ifI18nEnabled', function(options) {
  if (slices.i18n) {
    return options.fn(this);
  } else {
    return options.inverse(this);
  }
});
