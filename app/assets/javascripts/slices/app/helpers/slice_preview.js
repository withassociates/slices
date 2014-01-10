// Default slice-preview helper. If attachments are present it will emit
// 'n item(s)', otherwise it will simply emit the content of any textarea
// or text input.
//
// This method has been kept purposefully simple to encourage custom
// preview helpers.
//
// Example:
//
//     slices.defaultSlicePreview.call($('.slice-content'))
//
slices.defaultSlicePreview = function() {
  if (this.find('.attachment-list').length) {
    var count = this.find('.attachment-list li').length;
    return count + (count === 1 ? ' item' : ' items');
  } else {
    var html = this.find('textarea, input[type="text"]')
    .map(function() { return $(this).val() })
    .get()
    .join(' ');

    return $('<div />').html(html).text();
  }
}

// Define custom previews for slices using this helper.
//
// In true jQuery style, the context of the method `this` is the slice-content
// element (in this case wrapped in a jQuery object).
//
// If the helper is empty, the default slice preview helper will be used.
//
// Example:
//
//     {{#slicePreview}}
//       return this.find('input').val().toUpperCase();
//     {{/slicePreview}}
//
Handlebars.registerHelper('slicePreview', function(options) {
  try {
    var proc = options.fn && options.fn();
    if (proc.match(/\S/)) window.customSlicePreview = new Function(proc);
  } catch(error) {
    console.error('This slicePreview caused an error:\n' + proc);
    console.error(error);
  }
});

