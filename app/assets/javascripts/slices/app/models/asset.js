// Represents assets in a few different states. Simple assets as they exist
// in the Asset Library; Assets in use within a Slice; and Assets in the
// process of being uploaded.
slices.Asset = Backbone.Model.extend({

  urlRoot: '/admin/assets',

  // Filtered set of attrs
  toJSON: function() {
    return { asset: {
      name: this.get('name'),
      tags: this.get('tags')
    }};
  },

  isImage: function() {
    return (this.get('file_content_type') || '').indexOf('image') === 0;
  },

  // Okay, so this method involves a bit of reaching into the prototype
  // cookie jar, as Backbone doesn’t really have a way to subclass these
  // fundamental methods of models.
  destroy: function(options) {
    this.trigger('destroying');
    Backbone.Model.prototype.destroy.apply(this);
  }

});

