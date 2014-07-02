// Responsible for the managing the ui for a single attachment,
// used within AssetComposerView.
slices.AttachmentView = Backbone.View.extend({

  events: {
    'change' : 'update'
  },

  tagName: 'li',

  template: Handlebars.compile(
    '<div class="attachment-thumb"></div>' +
    '<div class="attachment-fields"></div>' +
    '<span data-action="remove" class="remove">&times;</span>'
  ),

  // Initialize the view.
  initialize: function() {
    _.bindAll(this);
    // Make view and model accessible from el.
    $(this.el).data('view', this);
    $(this.el).data('model', this.model);
  },

  // Render our template to this.el.
  render: function() {
    $(this.el).html(this.template(this));
    this.renderAssetThumb();
    this.renderFields();
    return this;
  },

  // If this attachment has an asset, we can render an AssetThumbView.
  // We make sure to switch of the selection functionality.
  renderAssetThumb: function() {
    if (!this.model.get('asset')) return;

    this.assetThumb = new slices.AssetThumbView({
      model: this.model.get('asset'),
      selectable: false,
      tagName: 'div'
    });

    this.$('.attachment-thumb').prepend(this.assetThumb.render().el);
  },

  // We don’t know what extra fields will come on the attachment, so we’ll
  // render this template using the attachment model’s attributes, rather
  // than `this`. Doesn’t provide the usual opportunities for overriding
  // and proxying, but much more flexible.
  renderFields: function() {
    if (!_.isFunction(this.options.fields)) return;

    this.$('.attachment-fields').
    html(this.options.fields(this.model.attributes)).
    applyDataValues().
    initDataPlugins();
  },

  // Remove this view and unbind any event handlers.
  remove: function() {
    this.model.unbind('change', this.render);
    $(this.el).remove();
  },

  // Write contents of fields to our model.
  update: function() {
    this.model.set(this.getValues());
  },

  // Retrieve values from our fields and return as an object.
  getValues: function() {
    var result = {};
    this.$('[name]').each(function() {
      var field = $(this);
      result[field.attr('name')] = slices.getValue(field);
    });
    return result;
  },

  // Update the upload progress information, wrapped around the file.
  updateFile: function(attrs) {
    this.assetThumb.updateFile(attrs);
  },

  // Update the upload progress information so we see happy face, then
  // wait for the thumbnail to load or happyTime, whichever is longer.
  updateFileAndComplete: function(file) {
    this.assetThumb.updateFileAndComplete(file);
  },

  // Returns the midpoint of the view, relative to the document.
  midPoint: function() {
    return {
      x: $(this.el).offset().left + ($(this.el).width() / 2),
      y: $(this.el).offset().top + ($(this.el).height() / 2)
    }
  }

});

