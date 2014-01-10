// An all-purpose value-grabber. This method has been extracted from a couple
// of different places in the codebase, and could do with a haircut.
slices.getValue = function(inp) {
  inp = $(inp);

  // If the input has a computed value assigned, return it.
  if (inp.data('computed-value')) {
    return inp.data('computed-value');

  // If the input is a special array type, return concatenated value.
  } else if (inp.data('type') === 'array') {
    return inp.val().split('||');

  // If the input is a checkbox, return true/false for checked/unchecked.
  } else if (inp.is(':checkbox')) {
    return inp.is(':checked');

  // If field contains a set of radio buttons, find checked and return value.
  } else if (inp.is(':has(:radio)')) {
    return inp.find(':checked').val();

  // Otherwise, this is simple input and we just take its value normally.
  } else {
    return inp.val();
  }
}

// Returns the value for a particular id.
slices.getValueForId = function(id) {
  return slices.getValue('#' + id);
}
