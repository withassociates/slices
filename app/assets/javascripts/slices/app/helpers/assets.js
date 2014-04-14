// Create an attachment composer for a collection
//
// Within the attachmentComposer, define the html for the fields the composer
// should display. Here, we’re assuming there’s a field on the slice called
// `slides`.
//
//     {{#attachmentComposer field="slides"}}
//       <textarea name="caption" class="full-height">{{caption}}</textarea>
//     {{/attachmentComposer}}
//
// By default, attachment composer does not allow the same asset to be added
// twice. To allow duplicates, set the `allowDupes` option to true:
//
//     {{#attachmentComposer field="slides" allowDupes=true}}
//       <textarea name="caption" class="full-height">{{caption}}</textarea>
//     {{/attachmentComposer}}
//
Handlebars.registerHelper('attachmentComposer', function(options) {
  if (!options.hash) {
    return new Handlebars.SafeString(
      '<code style="color: red">' +
        'DEPRECATION: Please use the new attachmentComposer syntax: ' +
        '{{attachmentComposer field="example"}}' +
      '</code>'
    );
  }

  // Instantiate an AssetComposerView.
  var composer = new slices.AttachmentComposerView({
    id         : slices.fieldId(this, options.hash.field),
    collection : this[options.hash.field],
    fields     : options.fn,
    autoAttach : true,
    allowDupes : options.hash.allowDupes
  });

  // Return the placeholder. Don’t worry, this is replaced automatically later.
  return new Handlebars.SafeString(composer.placeholder());
});

// Create a new AssetLibraryView and append it to the given `el`.
// If no `el` is given, render will write one in-place to the dom,
// and render it there.
//
// Rendering asset library at the current point in html
//
//     <script>slices.renderAssetLibrary({ mode: 'full' })</script>
//
slices.renderAssetLibrary = function(options) {
  options = options || {};
  if (!options.el) {
    document.write('<div id="asset-library" class="asset-library">');
    options.el = '#asset-library';
  }
  return new slices.AssetLibraryView(options);
}

// Returns the singlton asset drawer, which we’d normally just send close/open.
//
//     slices.assetDrawer().open();
//
slices.assetDrawer = function() {
  if (!slices._assetDrawer) {
    var el = $('<div id="asset-drawer" class="asset-library">').appendTo('body');
    slices._assetDrawer = slices.renderAssetLibrary({ el: el, mode: 'drawer' });
  }
  return slices._assetDrawer;
}

