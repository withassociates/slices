slices.FILE_QUEUED    = 'queued';
slices.FILE_UPLOADING = 'uploading';
slices.FILE_FAILED    = 'failed';
slices.FILE_DONE      = 'done';

slices.File = Backbone.Model.extend({

  defaults: {
    status: slices.FILE_QUEUED
  },

  initialize: function() {
    this.uploader = this.get('uploader');
    this.url = this.get('uploadOptions').url;
    this.params = this.get('uploadOptions').params;
  },

  start: function() {
    this.upload();
  },

  status: function() {
    switch(this.get('status')) {
    case slices.FILE_QUEUED:
      return 'queued';
    case slices.FILE_UPLOADING:
      if (this.progress() < 1) return 'uploading';
      else return 'processing';
    case slices.FILE_FAILED:
      return 'failed';
    case slices.FILE_DONE:
      return 'done';
    default:
      return 'queued';
    }
  },

  progress: function() {
    return this.get('loaded') / this.get('total');
  },

  formDataWithOptions: function(options) {
    var formData = new FormData();
    for (var i in options) {
      formData.append(i, options[i])
    }
    return formData;
  },

  formData: function() {
    var formData = this.formDataWithOptions(this.params);
    formData.append('file', this.get('browserFile'));
    return formData;
  },

  upload: function() {
    var self = this,
        url  = this.url,
        data = this.formData();

    this.uploadWithOptions(url, data, {
      progress: function(xhr, progress) { self.onProgress(progress) },
      success: function (response) { self.onSuccess(response) },
      error: function (response) { self.onError(response) }
    });
  },

  uploadWithOptions: function(url, data, callbacks) {
    var jqXHR = $.ajax({
      url         : url,
      data        : data,
      cache       : false,
      processData : false,
      type        : 'POST',
      contentType : false,
      progress    : callbacks.progress,
      success     : callbacks.success,
      error       : callbacks.error
    });
  },

  onProgress: function(progress) {
    if (!progress.lengthComputable) return;

    this.set({
      status: slices.FILE_UPLOADING,
      loaded: progress.loaded,
      total: progress.total
    });
  },

  onSuccess: function(response) {
    this.set('status', slices.FILE_DONE);
    this.uploader.onload({ file: this, response: response });
  },

  onError: function(response) {
    this.set('status', slices.FILE_FAILED);
    this.uploader.onfail({ file: this, response: response });
  }

});

