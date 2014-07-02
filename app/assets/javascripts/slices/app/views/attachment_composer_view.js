// Responsible for managing the ui for a collection of attachments. Works in
// conjunction with `AttachmentView`, `Attachment`, `AttachmentCollection`
// and specialized Handlebars helper `attachmentComposer`.
// A JSON description of the collection is written to the element’s
// data-computed-value, and subsequently read by Slices when saving the Page.
//
// This shouldn’t be instantiated directly.
// Instead, use `{{attachmentComposer}}` like this:
//
//     {{#attachmentComposer myAttachments}}
//       <textarea name="caption">{{caption}}</textarea>
//     {{/attachmentComposer}}
//
slices.AttachmentComposerView = Backbone.View.extend({

  DROP_THRESHOLD: 15,

  views: {}, // internal view cache

  events: {
    'click [data-action="library"]' : 'openAssetDrawer',
    'click [data-action="remove"]'  : 'removeClicked'
  },

  template: Handlebars.compile(
    '<ol class="attachment-list"></ol>' +
    '<div class="attachment-actions">' +
      '<button data-action="library">Choose from Library</button>' +
      '<button data-action="upload">Upload from computer</button>' +
    '</div>'
  ),

  className: 'attachment-composer',

  broadcastChanges: true,

  // Initialize the view. There are a few steps here, so read on.
  initialize: function() {
    _.bindAll(this);

    this.columns = this.options.columns || 1;

    // If this.options.collection is just a simple array, we need to
    // instantiate and AttachmentCollection.
    this.collection = new slices.AttachmentCollection(this.options.collection);
    this.collection.bind('add'    , this.addAttachment);
    this.collection.bind('remove' , this.removeAttachment);
    this.collection.bind('change' , this.update);
    this.collection.bind('reset'  , this.update);

    // Listen out for asset drags and drops.
    $(window).on('assets:dragStarted', this.onAssetDragStarted);

    if (this.options.autoAttach) {
      // Defer the attachment of the real view element.
      _.defer(this.attach);
    }
  },

  // Placeholder element to render into later.
  placeholder: function() {
    return Handlebars.compile('<div id="placeholder-{{id}}"></div>')(this);
  },

  render: function() {
    this.broadcastChanges = false;
    this.el.className = this.className + ' columns-' + this.columns;
    $(this.el).html(this.template(this));
    this.collection.each(this.addAttachment);
    this.makeSortable();
    this.makeUploader();
    this.update();
    this.broadcastChanges = true;
    return this;
  },

  // Replace our placeholder element with this.el.
  attach: function() {
    $('#placeholder-' + this.id).replaceWith(this.el);
    this.render();
  },

  // Add ui and references for an attachment.
  addAttachment: function(attachment, collection, options) {
    var view = new slices.AttachmentView({
      fields: this.options.fields,
      model: attachment
    });

    if (options.index < collection.length - 1) {
      view.$el.insertBefore(this.$('.attachment-list').children()[options.index]);
    } else {
      this.$('.attachment-list').append(view.el);
    }

    view.render();
    this.views[attachment.cid] = view;
    this.update();
  },

  // Remove ui and references for an attachment.
  removeAttachment: function(attachment) {
    var view = this.views[attachment.cid];
    view.remove();
    delete this.views[attachment.cid];
    if (attachment.file) this.uploader.removeFile(attachment.file);
    this.update();
  },

  // Write a JSON representation of the collection into data-computed-value
  // on this.el. Slices picks up on the computed-value when saving the page.
  // Ignores any items with a null asset_id, which are likely to be
  // failed uploads.
  update: function() {
    var value = this.collection.toJSON(),
        $el = $(this.el);

    value = _.reject(value, function(a) { return a.asset_id == null });
    $el.data('computed-value', value);
    $el[this.collection.isEmpty() ? 'removeClass' : 'addClass']('not-empty');
    if (this.broadcastChanges) $el.trigger('change');
  },

  // Infers a view and asset from just-clicked button and attempts to remove
  // the asset from the collection. Will prevent action if upload is in
  // progress - not ideal, but Plupload doesn't support cancelling an
  // in-progress uploader.
  removeClicked: function(e) {
    var button     = $(e.target),
        view       = button.parent('li'),
        attachment = view.data('model');

    this.collection.remove(attachment);
  },

  // Shows the asset library.
  openAssetDrawer: function(e) {
    e.preventDefault();
    e.stopImmediatePropagation();
    slices.assetDrawer().open({ step: this.assetDrawerStep });
  },

  assetDrawerStep: function() {
    var el = $(this.el),
        bottom = el.offset().top + el.outerHeight() + 30,
        drawerTop = $(slices.assetDrawer().el).offset().top;

    if (bottom > drawerTop) {
      var body = $('body');
      body.scrollTop(body.scrollTop() + (bottom - drawerTop));
    }
  },

  // Returns the Attachment view responsible for given File.
  viewForFile: function(file) {
    return this.views[file.attachment.cid];
  },

  // Make items sortable using jQuery UI sortable plugin.
  makeSortable: function() {
    this.$('.attachment-list').sortable({
      handle: '.attachment-thumb',
      scroll: false,

      beforeStart: _.bind(function(e, ui) {
        this.attachmentList().freezeHeight();
        window.autoscroll.start();
      }, this),

      stop: _.bind(function(e, ui) {
        this.attachmentList().thawHeight();
        window.autoscroll.stop();
      }, this),

      update: this.updateOnSort
    });
  },

  // Update collection to match the visible order of item elements.
  // We avoid jQuery.map here, because it returns some sort of weird
  // jquery object, rather than an array.
  updateOnSort: function() {
    var newOrder = _.map(this.$('.attachment-list li').get(), function(li) {
      return $(li).data('model');
    });
    this.collection.reset(newOrder);
  },

  // Create an uploader instance and bind up its callbacks.
  makeUploader: function() {
    this.uploader = new slices.Uploader({
      button : this.$('[data-action="upload"]'),
      drop   : this.el
    });
    this.uploader.bind('filesAdded', this.onFilesAdded);
    this.uploader.bind('fileUploaded', this.onFileUploaded);
  },

  // When files are added to the upload queue we create corresponding
  // attachment objects and add them to the collection.
  onFilesAdded: function(event) {
    var files = event.files,
        uploader = event.uploader;

    _(files).each(function(file) {
      var a = new slices.Attachment({
        asset: new slices.Asset({ file: file })
      });
      // This is clearly a code-smell, but it lets us easily look-up
      // the attachment-view for this file when events occur.
      file.attachment = a;
      // These bits are fine.
      this.collection.add(a);
      this.updateFileStatus(file);
    }, this);

    this.uploader.start();
  },

  // This looks weird, I know, but really all we’re doing is taking the
  // response from our upload to /assets and feeding it into our
  // attachment model.
  onFileUploaded: function(event) {
    var file = event.file,
        response = event.response,
        attachment = file.attachment,
        asset = attachment.get('asset');

    // Update the attachment model with just the new asset_id and update
    // the underlying asset with all the new info. This could do with
    // refactoring to make it better reveal its intent.
    attachment.set({ asset_id: response.id });
    asset.set(response);
    // Finally complete upload progress display and transition to thumbnail.
    this.viewForFile(file).updateFileAndComplete(file);
    // Need to update when uploads complete, so data('value') correctly
    // reflects all these attachments.
    this.update();
    // Send the signal to any asset library views.
    $(window).trigger('assets:uploadCompleted');
  },

  // Tell the appropriate attachment object to update against the file.
  // This needs to be deferred, for reasons mentioned above.
  updateFileStatus: function(file) {
    this.viewForFile(file).updateFile(file);
  },

  // The following methods implement the asset-receiver interface.
  // See slices.AssetLibraryView for details.

  onAssetDragStarted: function(e, library) {
    library.registerReceiver(this);
  },

  withinBounds: function(x, y) {
    var offset = $(this.el).offset(),
        top    = offset.top - this.DROP_THRESHOLD,
        left   = offset.left - this.DROP_THRESHOLD,
        bottom = top + $(this.el).height() + (this.DROP_THRESHOLD * 2),
        right  = left + $(this.el).width() + (this.DROP_THRESHOLD * 2);

    return x >= left && x <= right && y >= top && y <= bottom;
  },

  cursor: function() {
    return this._cursor = this._cursor || $('<li class="cursor">');
  },

  assetsOver: function(x, y) {
    this.$el.addClass('assets-over');

    // So as not to cause excessive re-flows, we only want to move the cursor
    // when the placement point actually changes.
    //
    // The following steps aren’t pretty, and could do with a refactor.
    //
    // Find the new placement point.
    var p = this.findPlacementPoint(x, y);
    // If we’ve a placement point in memory, and a new point was found,
    // and they share the same index, then we won’t be moving.
    var same = (this.placementPoint && p && this.placementPoint.index === p.index);
    // Commit the placement point to memory.
    this.placementPoint = p;
    // If the point hasn’t changed, duck out at this point.
    if (same) return;

    // If a placement point was found, insert the cursor before.
    if (p) {
      this.cursor().insertBefore(p.view.el);
    // Otherwise, just append to attachment-list.
    } else {
      this.cursor().appendTo(this.$('.attachment-list'));
    }
  },

  assetsNotOver: function() {
    this.$el.removeClass('assets-over');
    this.cursor().detach();
    delete this.placementPoint;
  },

  receiveAssets: function(assets, x, y) {
    var p = this.findPlacementPoint(x, y),
        position = p ? p.index : this.collection.length;

    _.each(assets, function(asset) {
      if (!this.options.allowDupes && this.alreadyContains(asset)) return;
      this.collection.add({ asset: asset, asset_id: asset.get('id') }, { at: position });
      position += 1;
    }, this);
  },

  // Returns the point at which an asset drop should be placed for the
  // given coordinates, as a Hash containing the following model, following
  // view and exact index for placement. If no suitable point is found, it
  // returns null.
  //
  //     findPlacementPoint(0, 0) //-> { attachment: a, view: v, :index: i }
  //
  findPlacementPoint: function(x, y) {
    var views = this.views;

    if (views.length === 0) return;

    var list = this.$('.attachment-list'),
        sampleItem = this.$('.attachment-list > li'),
        w = sampleItem.outerWidth(true),
        h = sampleItem.outerHeight(true),
        ox = list.offset().left,
        oy = list.offset().top,
        row,
        col,
        i,
        a,
        v;

    x = x - ox;
    y = y - oy;

    col = Math.floor(x / w);
    row = Math.floor(y / h);
    i = (row * this.columns) + col;

    a = this.collection.at(i);

    if (a) {
      v = views[a.cid];

      return { attachment: a, view: v, index: i };
    }
  },

  // Returns true if the given asset is already in our collection.
  alreadyContains: function(asset) {
    var id = asset.get('id');

    return this.collection.any(function(attachment) {
      return attachment.get('asset_id') === id;
    });
  },

  attachmentList: function() {
    return this.$('.attachment-list');
  }

});

