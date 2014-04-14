slices.ENTRY_TEMPLATES = {
  name: function(key) {
    return '<td class="name"><a href="{{url}}">{{name}}</a></td>';
  },

  url: function(key) {
    return null;
  },

  _default: function(key) {
    return '<td class="{{' + key + '}}">{{' + key + '}}</td>';
  }
};


/*
 * Registers an entry template function for the given key.
 * The function takes `key` and should return a string.
 * Template compilation happens elsewhere.
 *
 * @param {String} key
 * @param {Function} fun
 */

slices.registerEntryTemplate = function(key, fun) {
  slices.ENTRY_TEMPLATES[key] = fun;
}

/*
 * Returns the entry template for the given key.
 *
 * If not special templates are registered, the default
 * template is returned.
 *
 * @return {String}
 */

slices.entryTemplate = function(key) {
  var fun = slices.ENTRY_TEMPLATES[key] || slices.ENTRY_TEMPLATES['_default'];
  return fun(key);
}
