// Radio field
//
// This shouldn’t be instantiated directly.
// Instead, use `{{radioField}}` like this:
//
//     {{#radioField field="example"}}
//       <input type="radio" value="one">
//       <input type="radio" value="two">
//       <input type="radio" value="three">
//     {{/radioField}}
//
slices.RadioFieldView = Backbone.View.extend({

  // -- Config --

  events: {
    'change input[type="radio"]' : 'onChangeRadio'
  },

  className: 'radio-field',

  template: Handlebars.compile(
    '<div class="radio-options"></div>' +
    '<input class="radio-value" type="hidden" name="{{name}}" value="{{value}}">'
  ),

  // -- Init --

  initialize: function() {
    _.bindAll(this);
    this.name = this.options.name;
    this.value = this.options.value;
    this.inner = this.options.inner;
    if (this.options.autoAttach) _.defer(this.attach);
  },

  // -- Rendering --

  placeholder: function() {
    return Handlebars.compile('<div id="placeholder-{{id}}"></div>')(this);
  },

  attach: function() {
    $('#placeholder-' + this.id).replaceWith(this.el);
    this.render();
  },

  render: function() {
    var value = this.value;

    $(this.el).html(this.template(this));
    this.$('.radio-options').html(this.inner);
    this.$('input[type="radio"]').each(function() {
      if ($(this).val() == value) $(this).attr('checked', 'checked');
    });

    return this;
  },

  // -- Event Handlers --

  onChangeRadio: function(event) {
    this.value = event.target.value;
    this.render();
  }

});
