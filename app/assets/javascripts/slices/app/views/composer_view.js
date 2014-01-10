slices.ComposerView = Backbone.View.extend({

  className: 'composer',

  template: Handlebars.compile(
    '<ol class="composer-item-list"></ol>' +
    '<div class="composer-actions">' +
      '<button data-action="add">{{addLabel}}</button>' +
    '</div>'
  ),

  events: {
    'click [data-action="add"]'    : 'didClickAdd',
    'click [data-action="remove"]' : 'didClickRemove'
  },

  addLabel: 'Add An Item',

  broadcastChanges: true,
  views: {},

  initialize: function() {
    _.bindAll(this);

    this.addLabel = this.options.addLabel || this.addLabel;

    this.collection = new slices.ComposerItemCollection(this.options.value);
    this.collection.bind('add'    , this.addItem);
    this.collection.bind('remove' , this.removeItem);
    this.collection.bind('change' , this.update);
    this.collection.bind('reset'  , this.update);

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
    this.broadcastChanges = false;
    this.$el.html(this.template(this));
    this.collection.each(this.addItem);
    this.makeSortable();
    this.update();
    this.broadcastChanges = true;
    return this;
  },

  makeSortable: function() {
    var list = this.$('.composer-item-list');

    list.sortable({
      handle: '[data-role="drag-handle"]',
      scroll: false,

      beforeStart: _.bind(function(e, ui) {
        list.freezeHeight();
        window.autoscroll.start();
      }, this),

      stop: _.bind(function(e, ui) {
        list.thawHeight();
        window.autoscroll.stop();
      }, this),

      update: this.updateOnSort
    });
  },

  updateOnSort: function() {
    var items = this.$('.composer-item-list').children();

    var newOrder = items.map(function() {
      return $(this).data('model');
    }).get();

    this.collection.reset(newOrder);
  },

  update: function() {
    var value = this.collection.toJSON();
    this.$el.data('computed-value', value);
    this.$el[this.collection.isEmpty() ? 'removeClass' : 'addClass']('not-empty');
    if (this.broadcastChanges) this.$el.trigger('change');
  },

  addItem: function(item, collection, options) {
    var view = new slices.ComposerItemView({
      fields: this.options.fields,
      model: item
    });

    this.$('.composer-item-list').append(view.el);

    view.render();
    this.views[item.cid] = view;
    this.update();
  },

  removeItem: function(item) {
    var view = this.views[item.cid];
    view.remove();
    delete this.views[item.cid];
    this.update();
  },

  didClickAdd: function(e) {
    e.preventDefault(); e.stopImmediatePropagation();
    this.collection.add({});
  },

  didClickRemove: function(e) {
    e.preventDefault(); e.stopImmediatePropagation();

    var button = $(e.target),
        view   = button.closest('li'),
        item   = view.data('model');

    this.collection.remove(item);
  }

});
