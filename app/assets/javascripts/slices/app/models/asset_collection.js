// This is our connection to the Asset library.
slices.AssetCollection = Backbone.Collection.extend({

  model: slices.Asset,

  url: '/admin/assets',

  initialize: function() {
    this.bind('add', this.afterAdd);
    this.bind('remove', this.afterRemove);
  },

  // This request responds with a page worth of results in `items`.
  parse: function(response) {
    this.currentPage = response.current_page;
    this.perPage = response.per_page;
    this.totalEntries = response.total_entries
    this.totalPages = response.total_pages;
    return response.items;
  },

  // Returns true if there are more pages in the current criteria.
  hasMorePages: function() {
    return this.currentPage < this.totalPages;
  },

  // After an asset is added, we need to update the non-standard
  // totalEntries count.
  afterAdd: function() {
    this.totalEntires += 1;
    this.totalPages = Math.ceil(this.totalEntries / this.perPage);
  },

  // Similarly, we need to update the count on remove.
  afterRemove: function() {
    this.totalEntries -= 1;
    this.totalPages = Math.ceil(this.totalEntries / this.perPage);
  }

});

