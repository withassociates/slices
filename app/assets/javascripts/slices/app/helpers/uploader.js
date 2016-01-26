// Returns a freshly prepared slices.Uploader instance.
//
//     new slices.Uploader({
//       button : '#my-button',
//       drop   : '#my-drop-target',
//       params : {}
//     });
//
'use strict';

slices.Uploader = function(options) {
  this.options = $.extend({}, this.options, options);
  this.initialize();
}
$.extend(slices.Uploader.prototype, Backbone.Events, {

  // Default options
  options: {
    url: '/admin/assets.json'
  },

  initialize: function() {
    this.files = [];

    this.button = $(this.options.button);
    this.input  = this.createInput();
    this.drop   = $(this.options.drop);

    this.configureCSRF();
    this.observeEvents();
  },

  configureCSRF: function() {
    var csrfParam = $('meta[name="csrf-param"]').attr('content'),
        csrfToken = $('meta[name="csrf-token"]').attr('content');

    this.options.params = this.options.params || {};
    this.options.params[csrfParam] = csrfToken;
  },

  createInput: function() {
    return $('<input />', {
      type     : 'file',
      multiple : 'multiple',
      style    : 'position: absolute; visibility: hidden'
    }).appendTo('body');
  },

  observeEvents: function() {
    var self = this;

    this.input.on('change', function(e) { self.onInputChange(e) });
    this.button.on('click', function(e) { self.onButtonClick(e) });
    this.drop.on('dragenter', false);
    this.drop.on('dragover', false);
    this.drop.on('drop', function(e) { self.onDrop(e) });
  },

  onInputChange: function(event) {
    this.addFiles(this.input.prop('files'));
    this.input.val('');
  },

  onButtonClick: function(event) {
    event.preventDefault();
    this.input.click();
  },

  onDrop: function(event) {
    event.preventDefault();
    this.addFiles(event.originalEvent.dataTransfer.files);
  },

  addFiles: function(fileList) {
    var self = this;
    _(fileList).each(function(browserFile) {
      var file = new slices.fileClass({
        uploader      : this,
        uploadOptions : this.uploadOptions(),
        browserFile   : browserFile
      });
      self.files.push(file);
    }, this);

    this.trigger('filesAdded', { uploader: this, files: this.files });
  },

  uploadOptions: function() {
    return {
      url: this.options.url,
      params: this.options.params
    };
  },

  start: function() {
    // Only start uploading if there are files to upload...
    // and there is not a current file
    if (this.files.length == 0 || this.file != undefined) {
      return false;
    }

    // Take the first file from the list and start the upload
    this.file = this.files.shift();
    this.file.start();
  },

  onprogress: function(event) {
    this.trigger('fileProgress', event);
  },

  onload: function(event) {
    this.trigger('fileUploaded', event);
    this.file = undefined;
    this.start();
  },

  onfail: function(event) {
    this.trigger('fileError', event);
    this.file = undefined;
    this.start();
  },

  toString: function() {
    return 'slices.Uploader';
  }

});
