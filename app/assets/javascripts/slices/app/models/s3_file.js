slices.S3File = slices.File.extend({

  setS3Key: function(name) {
    this.set('key', slices.S3_TEMPFILE_KEY_PREFIX + '/' + Date.now() + '/' + name);
  },

  fileS3URL: function() {
    return slices.S3_URL + this.get('key');
  },

  formDataToS3: function() {
    var formData = this.formDataWithOptions(slices.S3_UPLOADER_DEFAULTS);
    var browserFile = this.get('browserFile');

    this.setS3Key(browserFile.name);
    formData.append('key', this.get('key'));
    formData.append('Content-Type', browserFile.type);
    formData.append('file', browserFile);
    return formData;
  },

  formDataFromS3: function() {
    var formData = this.formDataWithOptions(this.params);
    formData.append('file', this.fileS3URL());
    return formData;
  },

  upload: function() {
    var self = this,
        url  = slices.S3_URL,
        data = this.formDataToS3();

    this.uploadWithOptions(url, data, {
      progress: function(xhr, progress) { self.onS3Progress(progress) },
      success: function(response) { self.onS3Success(response) },
      error: function(response) { self.onS3Error(response) }
    });
  },

  onS3Progress: function(progress) {
    this.onProgress(progress);
  },

  onS3Success: function(response) {
    this.uploadToSlicesFromS3(response);
  },

  onS3Error: function(response) {
    this.onError(response);
  },

  uploadToSlicesFromS3: function() {
    var self = this,
        url  = this.url,
        data = this.formDataFromS3();

    this.uploadWithOptions(url, data, {
      progress: function() {},
      success: function(response) { self.onSuccess(response) },
      error: function(error) { self.onError(error) }
    });
  },

});
