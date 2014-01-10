slices.ComposerItemView = Backbone.View.extend({

  tagName: 'li',
  className: 'composer-item',

  template: Handlebars.compile(
    '<div class="item-fields"></div>' +
    '<span data-role="drag-handle"></span>' +
    '<span data-action="remove">Remove</span>'
  ),

  events: {
    'change': 'update'
  },

  initialize: function() {
    _.bindAll(this);
    this.$el.data('model', this.model);
  },

  render: function() {
    $(this.el).html(this.template(this));
    this.renderFields();
    return this;
  },

  renderFields: function() {
    if (!_.isFunction(this.options.fields)) return;

    this.$('.item-fields')
    .html(this.options.fields(this.model.attributes))
    .applyDataValues()
    .initDataPlugins();
  },

  remove: function() {
    this.model.unbind('change', this.render);
    this.$el.remove();
  },

  update: function() {
    this.model.set(this.getValues());
  },

  getValues: function() {
    var result = {};
    this.$('[name]').each(function() {
      var field = $(this);
      result[field.attr('name')] = field.val();
    });
    return result;
  }

});
