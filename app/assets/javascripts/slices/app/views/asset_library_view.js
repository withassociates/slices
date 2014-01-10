// The asset library is dedicated to browsing, searching and managing of
// assets. It can be rendered in-place, or to a specific element using the
// helper method.
//
// To render the library inline in html:
//
//     <script>slices.renderAssetLibrary()</script>
//
// Otherwise:
//
//     slices.renderAssetLibrary({ el: '#my-target' })
//
slices.AssetLibraryView = Backbone.View.extend({

  DRAG_THRESHOLD: 15,

  DRAWER_HEIGHT: 250,

  events: {
    'keyup [type="search"]'          : 'search',
    'click [type="search"]'          : 'search',
    'click [data-action="close"]'    : 'close',
    'click [data-action="show-all"]' : 'showAll',
    'mousedown .library-container'   : 'backgroundPress',
    'mousedown .resize-handle'       : 'startResize'
  },

  thumbs: {},

  selection: [],

  currentSearchTerm: '',

  className: 'asset-library',

  // We include the full template here, so the view can be rendered anywhere
  // without html needing to be present ahead of time.
  template: Handlebars.compile(
    '<div class="toolbar">' +
      '{{{resizeHandle}}}' +
      '<input type="search" id="assets-search" placeholder="Search assets...">' +
      '<div class="count"></div>' +
      '{{{hint}}}' +
      '<div class="actions"><ul>{{actions}}</ul></div>' +
    '</div>' +
    '<div class="library-container">' +
      '<ul class="library"></ul>' +
    '</div>'
  ),

  // The collection is instantiated during initialization, as this is an
  // 'AppView' style class.
  initialize: function() {
    _.bindAll(this);

    this.collection = new slices.AssetCollection();
    this.collection.bind('add', this.add);
    this.collection.bind('remove', this.remove);
    this.collection.bind('reset', this.reset);
    $(window).on('assets:uploadCompleted', this.fetch);

    this.render();

    this.scrollArea = this.$('.library-container');
    this.scrollArea.on('scroll', this.onScroll);

    this.initializeUploader();

    this.showLoadingSpinner();

    this.fetch();
  },

  render: function() {
    $(this.el).html(this.template(this));
    return this;
  },

  // Clear all thumbs on display and re-render the collection.
  reset: function() {
    this.clearThumbs();
    this.collection.each(this.add);
  },

  // Create a thumb view for the model, render it, and stick it in
  // our reference hash.
  add: function(model) {
    var thumb = new slices.AssetThumbView({ model: model, selectable: true });
    thumb.bind('thumb:press', this.thumbPress);
    thumb.bind('thumb:release', this.thumbRelease);
    thumb.bind('thumb:blur', this.thumbBlur);
    this.loadingSpinner().before(thumb.render().el);
    this.thumbs[model.cid] = thumb;
    this.updateCount();
  },

  // Ask the thumb view to remove itself, and delete the reference.
  remove: function(model) {
    this.clearThumb(model.cid);
    this.updateCount();
  },

  // Handle special keystrokes, or defer to our debounced general search.
  search: function(e) {
    if (e.which == 27) this.$('[type="search"]').val('');
    this._search(e);
  },

  // This debounced method actually performs the search on our collection.
  _search: _.debounce(function(e) {
    var term = this.searchTerm();

    if (term === this.currentSearchTerm) return;

    this.currentSearchTerm = term;
    this.fetch();
  }, 300),

  // Assuming we’re in upload-view, take us back to normal.
  showAll: function() {
    if (this.uploader.files.length > 0) {
      alert('Uploads are still in progress, please wait for them to finish.');
    } else {
      this.fetch();
    }
  },

  // Remove all thumb views currently on display.
  clearThumbs: function() {
    this.updateCount('Searching…');
    for (var cid in this.thumbs) this.clearThumb(cid);
  },

  // Remove a specific thumb.
  clearThumb: function(cid) {
    var thumb = this.thumbs[cid];
    this.selection = _(this.selection).without(thumb);
    thumb.remove();
    delete this.thumbs[cid];
  },

  // Helper method for getting the value of the search field.
  searchTerm: function() {
    return this.$('[type="search"]').val();
  },

  // If we’re in drawer mode, we’ll display a hint that users should
  // drag and drop.
  hint: function() {
    if (this.options.mode === 'drawer') {
      return '<div class="hint">Drag &amp; drop to place on the page</div>';
    }
  },

  // If we’re in drawer mode, we’ll add a resize handle in here.
  resizeHandle: function() {
    if (this.options.mode === 'drawer') {
      return '<div class="resize-handle"></div>';
    }
  },

  // We render different action button depending on the mode.
  actions: function() {
    var actions = [];

    actions.push('<li><a class="button" data-action="upload">Upload</a></li>');

    if (this.options.mode === 'drawer') {
      actions.push('<li><a class="button" data-action="close">Close</a></li>');
    }

    return new Handlebars.SafeString(actions.join(''));
  },

  // The open and close methods only apply if in 'drawer' mode.
  open: function(options) {
    $('#container').stop().animate({ paddingBottom: this.DRAWER_HEIGHT + 'px' });
    $(this.el).stop().animate(
      { height: this.DRAWER_HEIGHT + 'px' },
      _.extend({}, options, { complete: this.afterOpen })
    );
  },
  afterOpen: function() {
    this.$('input[type="search"]')[0].focus();
  },
  close: function() {
    this.$('input[type="search"]')[0].blur();
    $('#container').stop().animate({ paddingBottom: '0px' });
    $(this.el).stop().animate({ height: '0px' });
  },

  // Thumb press/release behaviour mimicks that of operating system file
  // selection. Holding down shift selects ranges of files, with memory of
  // the anchor. Holding down cmd/ctrl selects multiple assets. Clicks
  // without modifiers select single assets.
  //
  // This method is disgraceful at the moment, because there are a few
  // modes of behaviour. It’s an ideal candidate for refactoring.
  thumbPress: function(event, thumb) {
    _.invoke(this.selection, 'deselect');

    if (event.shiftKey) {
      if (this.selection.length === 0) {
        this.selection.push(thumb);
        this.selectionAnchor = thumb;
      } else {
        var first   = this.selectionAnchor,
            start   = this.collection.indexOf(first.model),
            end     = this.collection.indexOf(thumb.model),
            lowest  = Math.min(start, end),
            highest = Math.max(start, end);

        this.selection = [];

        for (var i = lowest; i <= highest; i++) {
          var thumb = this.thumbs[this.collection.at(i).cid];
          this.selection.push(thumb);
        }
      }
    } else if (event.metaKey) {
      if (_(this.selection).include(thumb)) {
        this.selection = _(this.selection).without(thumb);
      } else {
        this.selection.push(thumb);
      }
      this.selectionAnchor = _.sortBy(this.selection, function(thumb) {
        return thumb.model.collection.indexOf(thumb.model);
      })[0];
    } else {
      if (!_(this.selection).include(thumb)) {
        this.selection = [thumb];
        this.selectionAnchor = thumb;
      }
    }

    _.invoke(this.selection, 'select');

    if (this.selection.length > 0) this.prepareForDrag(event);

    this.listenForKeys();
  },

  // Most selection releated behaviours happen on mousedown. The exception
  // is when multiple assets are selected - a single unmodified click will
  // set the selection to the clicked asset, but only when the mouse is
  // released.
  thumbRelease: function(event, thumb) {
    if (event.metaKey || event.shiftKey) return;

    _.invoke(this.selection, 'deselect');
    this.selection = [thumb];
    this.selectionAnchor = thumb;
    _.invoke(this.selection, 'select');
  },

  // Thumb Blur is not the best name, but this basically implies that an
  // action has taken place which should cause asset library thumb-related
  // actions to take a back-seat. This is used when the asset editor is
  // opened.
  thumbBlur: function() {
    this.deselectAll();
  },

  // When the background is pressed, the selection is cleared out.
  backgroundPress: function(event) {
    if (event.shiftKey || event.metaKey) return;
    event.preventDefault();
    event.stopImmediatePropagation();
    this.deselectAll();
  },

  // Deselect all thumbs and trigger appropriate actions.
  deselectAll: function() {
    _.invoke(this.selection, 'deselect');
    this.selection = [];
  },

  // Array of models from the current selection.
  selectedAssets: function() {
    return _.pluck(this.selection, 'model');
  },

  // Update the UI count of asset(s) found.
  updateCount: function(message) {
    this.$('.count').html(message || this.countMessage());
  },

  // Messages for different asset counts.
  countMessages: {
    default: {
      none: Handlebars.compile('No assets, yet…'),
      one: Handlebars.compile('Showing 1 asset'),
      some: Handlebars.compile(
        'Showing latest {{count}} assets of {{total}} total'
      ),
      all: Handlebars.compile(
        'Showing all {{count}} assets, latest first'
      )
    },
    uploads: {
      one: Handlebars.compile(
        'Showing 1 new asset ' +
        '(<a data-action="show-all">Show everything</a>)'
      ),
      some: Handlebars.compile(
        'Showing {{count}} new assets ' +
        '(<a data-action="show-all">Show everything</a>)'
      ),
    },
    search: {
      none: Handlebars.compile('No matching assets'),
      one: Handlebars.compile('Showing 1 matching asset'),
      some: Handlebars.compile(
        'Showing latest {{count}} matching assets of {{total}} total'
      ),
      all: Handlebars.compile(
        'Showing all {{count}} maching assets, latest first'
      )
    }
  },

  // Returns the appropriate message count for the current context.
  countMessage: function() {
    var t = this.countMessages,
        total = this.collection.totalEntries,
        count = this.collection.length;

    if (this.inUploadView) {
      t = t.uploads;

      if (count === 1) {
        return t.one({ count: count });
      } else {
        return t.some({ count: count });
      }
    } else {
      t = this.currentSearchTerm ? t.search : t.default;

      if (total === 0) {
        return t.none();
      } else if (total === 1) {
        return t.one();
      } else if (total > count) {
        return t.some({ total: total, count: count });
      } else {
        return t.all({ total: total, count: count });
      }
    }
  },

  NEXT_PAGE_THRESHOLD: 600,

  // Potentially load more entries on scroll.
  onScroll: _.debounce(function(e) {
    if (this.loading) return;
    if (this.inUploadView) return;

    var library      = this.$('.library'),
        scrollTop    = this.scrollArea.scrollTop(),
        scrollBottom = scrollTop + this.scrollArea.height(),
        remaining    = library.height() - scrollBottom;

    if (remaining <= this.NEXT_PAGE_THRESHOLD && this.collection.hasMorePages()) {
      this.showLoadingSpinner();
      this.fetch({ add: true });
    }
  }, 300),

  // Spinner graphic, revealed as necessary.
  loadingSpinner: _.memoize(function() {
    return $(
      '<li class="loading-indicator">' +
        '<span class="label">Loading&hellip;</label>' +
       '</li>'
    ).appendTo(this.$('.library'));
  }),

  showLoadingSpinner: function() {
    this.loadingSpinner().css({ display: 'block' });
  },

  hideLoadingSpinner: function() {
    this.loadingSpinner().css({ display: 'none' });
  },

  // Wrapper around the collection’s fetch method. Takes seach
  // and paging into account.
  fetch: function(options) {
    options = _.extend({ add: false }, options);

    this.loading = true;

    this.exitUploadView();
    this.showLoadingSpinner();

    if (!options.add) this.collection.reset();

    this.collection.fetch({
      data: {
        search: this.searchTerm(),
        page: options.add ? (this.collection.currentPage + 1) : 1
      },
      add: options.add,
      success: this.onFetchSuccess
    });
  },

  // Hide spinner and set loading state back to false.
  onFetchSuccess: function() {
    this.loading = false;
    this.hideLoadingSpinner();
    this.updateCount();
  },

  // ## Drag-Drop API:
  //
  // Any object can hook into AssetLibrary’s drag-drop API by
  // implementing the following protocol:
  //
  // Bind to the `assets:dragStarted` event and register to receive assets:
  //
  //     var self = this;
  //
  //     $(window).on('assets:dragStarted', function(event, library) {
  //       library.registerReceiver(self);
  //     });
  //
  // Implement the `withinBounds` method:
  //
  //     this.withinBounds = function(x, y) {
  //       // Return true or false
  //     }
  //
  // Implement the `assetsOver` method:
  //
  //     this.assetsOver = function(x, y) { ... }
  //
  // Implement the `assetsNotOver` method:
  //
  //     this.assetsNotOver = function() { ... }
  //
  // Implement the `receiveAssets` method:
  //
  //     this.receiveAssets = function(assets, x, y) { ... }
  //

  // Store the originating click, and bind onto relevant mouse events.
  prepareForDrag: function(e) {
    $(document).on('mousemove', this.onDrag).
                on('mouseup', this.stopDrag);

    this.dragOrigin = { x: e.pageX, y: e.pageY };
  },

  // If we’ve already started dragging, update the little helper so it follows
  // the user’s mouse pointer around. Otherwise, test if we’ve crossed the
  // threshold yet.
  onDrag: function(e) {
    if (this.dragging) {
      this.dragHelper.css({ left: e.pageX + 'px', top: e.pageY + 'px' });
      this.reviewReceiversForDrag(e.pageX, e.pageY);
    } else {
      this.testDragTreshold(e);
    }
  },

  // Dragging only begins when the mouse is dragged over DRAG_TRESHOLD.
  testDragTreshold: function(e) {
    var absDelta = Math.max(
      Math.abs(e.pageX - this.dragOrigin.x),
      Math.abs(e.pageY - this.dragOrigin.y)
    );

    if (absDelta >= this.DRAG_THRESHOLD) this.startDrag(e);
  },

  // Set the dragging state to true and create the drag helper -
  // the collection of little thumbs representing the current selection.
  startDrag: function(e) {
    this.dragging = true;

    this.dragHelper = $('<span class="asset-drag-helper">');
    this.dragHelper.css({ position: 'absolute' });

    for (var i in this.selection) { var thumb = this.selection[i];
      var img = thumb.$('img').clone(false);
      this.dragHelper.append(img);
    }

    this.dragHelper.appendTo('body');

    var width = Math.ceil(Math.sqrt(this.selection.length)) *
    (this.dragHelper.width() / this.selection.length);

    this.dragHelper.width(width);

    this.receivers = [this];

    $(window).trigger('assets:dragStarted', this);

    window.autoscroll.start();

    this.onDrag(e);
  },

  // Unbind mousey events, delete the drag helper, and inform potenital
  // recipients that a drop is taking place.
  stopDrag: function(e) {
    $(document).off('mousemove', this.onDrag).
                off('mouseup', this.stopDrag);

    window.autoscroll.stop();

    if (this.dragHelper) {
      this.dragHelper.remove();
      delete this.dragHelper;
    }

    delete this.dragging;

    this.reviewReceiversForDrop(e.pageX, e.pageY);
    delete this.receivers;
  },

  // Registers a potential asset receiver. Receivers are polled in order.
  registerReceiver: function(receiver) {
    this.receivers.push(receiver);
  },

  // On drag, we’ll want to send `assetsNotOver` to all receivers,
  // then identify the receiver under the cursor (if any) and it
  // `assetsOver`.
  reviewReceiversForDrag: function(x, y) {
    var receiver = this.identifyReceiver(x, y);

    _.each(this.receivers, function(r) {
      if (r !== receiver) r.assetsNotOver();
      else r.assetsOver(x, y);
    });
  },

  // On drop, we’ll identify the receiver under the cursor and send
  // `receiveAssets`, with the current selection.
  reviewReceiversForDrop: function(x, y) {
    _.invoke(this.receivers, 'assetsNotOver');
    var receiver = this.identifyReceiver(x, y);
    if (receiver) receiver.receiveAssets(this.selectedAssets(), x, y);
  },

  // Find the first receiver in the stack for which `withinBounds`
  // returns true.
  identifyReceiver: function(x, y) {
    return _.find(this.receivers, function(receiver) {
      return receiver.withinBounds(x, y);
    });
  },

  // Internal implementation of asset-receiver interface.
  //
  // The library itself is first on the stack of receivers.
  // So, if an asset payload is over the library,
  // it will get be the identified receiver.

  withinBounds: function(x, y) {
    var offset = $(this.el).offset(),
        top    = offset.top,
        left   = offset.left,
        bottom = top + $(this.el).height(),
        right  = left + $(this.el).width();

    return x >= left && x <= right && y >= top && y <= bottom;
  },

  assetsOver: function() {},
  assetsNotOver: function() {},
  receiveAssets: function() {},

  keydown: function(e) {
    if (this.selection.length > 0 && e.which === 8) {
      e.preventDefault();
      e.stopImmediatePropagation();
      this.destroySelection();
    }
  },

  // Destroy the selected assets. This sends 'destroy' to each asset
  // indvidually. If the responses to the DELETE requests are a bit slow,
  // then this can look a little inelegant.
  destroySelection: function() {
    if (this.selection.length === 1) {
      var message = 'Are you sure you want to delete this asset?';
    } else {
      var message = Handlebars.compile(
        'Are you sure you want to delete these {{count}} assets?'
      )({ count: this.selection.length });
    }

    if (confirm(message)) {
      _.invoke(this.selectedAssets(), 'destroy');
    }
  },

  // When this mode is switched on, AssetLibrary will listen out globally
  // for keydown events; primarily to catch the delete key at the moment.
  //
  // If a click is encountered outside the area of the library, we jump
  // out of this mode.
  listenForKeys: function() {
    if (this.listeningForKeys) return;
    this.listeningForKeys = true;
    $(window).on('keydown', this.keydown);
    $(window).one('mousedown', this.stopListeningForKeys);
  },

  // Jump out of keydown-aware mode.
  stopListeningForKeys: function() {
    this.listeningForKeys = false;
    $(window).off('keydown', this.keydown);
  },

  startResize: function(e) {
    e.preventDefault();
    e.stopImmediatePropagation();

    this.resizeOrigin = { y: e.pageY, h: this.$el.height() };

    $(window).on('mousemove', this.performResize).
              on('mouseup', this.endResize);
  },

  performResize: function(e) {
    var delta = e.pageY - this.resizeOrigin.y,
        height = Math.max(this.resizeOrigin.h - delta, this.DRAWER_HEIGHT);

    this.$el.height(height);
  },

  endResize: function(e) {
    $('#container').css({ paddingBottom: this.$el.height() + 'px' });
    $(window).off('mousemove', this.performResize).
              off('mouseup', this.endResize);
  },

  // Enables upload-to-library functionality.
  initializeUploader: function() {
    if (this.uploader) return;

    this.uploader = new slices.Uploader({
      button : this.$el.find('[data-action="upload"]'),
      drop   : this.$el.find('.library-container')
    });
    this.uploader.on('filesAdded', this.onFilesAdded);
    this.uploader.on('fileUploaded', this.onFileUploaded);
  },

  // When files are added to the upload queue we create corresponding
  // asset objects and add them to the collection.
  onFilesAdded: function(event) {
    this.enterUploadView();

    _(event.files).each(function(file) {
      var a = new slices.Asset({ file: file });
      // This is clearly a code-smell!
      file.asset = a;
      // These bits are fine.
      this.collection.add(a);
      this.updateFileStatus(file);
    }, this);

    this.uploader.start();
  },

  // This looks weird, I know, but really all we’re doing is taking the
  // response from our upload to /assets and feeding it into our
  // asset model.
  //onFileUploaded: function(uploader, file, transport) {
  onFileUploaded: function(event) {
    var file = event.file,
        response = event.response;

    // Update the attachment model. Silently, because we want to control
    // how it redraws.
    var asset = file.asset;
    asset.set(response);
    // Finally complete upload progress display and transition to thumbnail.
    this.viewForFile(file).updateFileAndComplete(file);
  },

  // When uploading files we just display the new uploads. All this does is
  // clear the current collection. There's also a catch in there to ensure
  // we don’t accidentally clear the collection when we don’t mean to.
  enterUploadView: function() {
    if (this.inUploadView) return;
    this.inUploadView = true;
    this.collection.reset();
    this.$('[type="search"]').hide();
    this.updateCount('Uploading…');
  },

  // When we’re no longer concerned with just our uploaded files, we return
  // to normal.
  exitUploadView: function() {
    if (!this.inUploadView) return;
    this.inUploadView = false;
    this.$('[type="search"]').show();
    this.updateCount();
  },

  // Passes information from upload on to the file’s view.
  updateFileStatus: function(file) {
    this.viewForFile(file).updateFile(file);
  },

  // Returns the view object associated with the given file.
  viewForFile: function(file) {
    return this.thumbs[file.asset.cid];
  }

});

