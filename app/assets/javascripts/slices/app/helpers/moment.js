Handlebars.registerHelper('moment', function(date, options) {
  var m = moment(date);
  var format = options.hash.format;

  if (format && format !== 'calendar') {
    return m.format(format);
  } else {
    return m.calendar();
  }
});
