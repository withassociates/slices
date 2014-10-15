// URL field
//
// This shouldn’t be instantiated directly.
// Instead, use `{{urlField}}` like this:
//
//     {{urlField field="example"}}
//
slices.UrlFieldView = Backbone.View.extend({

  // -- Config --

  tagName: 'input',
  className: 'url-field',

  attributes: {
    'type': 'text',
    'data-store': '/admin/pages/search.json?query=:query',
    'data-template': '#livefield-result-template'
  },

  // -- Init --

  initialize: function() {
    _.bindAll(this);
    if (this.options.autoAttach) _.defer(this.attach);
  },

  // -- Rendering --

  placeholder: function() {
    return Handlebars.compile('<div id="placeholder-{{id}}"></div>')(this);
  },

  attach: function() {
    $('#placeholder-' + this.id).replaceWith(this.el);
    $(this.el).val(this.options.value);
    this.render();
  },

  render: function() {
    $(this.el).livefield();
    return this;
  }
});
