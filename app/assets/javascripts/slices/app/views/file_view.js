// Responsible for the displaying the progress of a current upload.
slices.FileView = Backbone.View.extend({

  className: 'upload-info',

  textTemplate: Handlebars.compile(
    '<span class="upload-name">{{name}}</span>' +
    '<span class="upload-summary">{{summary}}</span>'
  ),

  imagePath: Handlebars.compile('/assets/slices/icon_upload_{{name}}.png'),

  possibleStatusList: [
    'status-queued',
    'status-uploading',
    'status-processing',
    'status-done',
    'status-failed'
  ].join(' '),

  // Create and append canvas and text then bind up the model.
  initialize: function() {
    _.bindAll(this);
    this.canvas = $('<canvas class="canvas" width="140" height="180" />');
    this.text = $('<div class="text" />');
    $(this.el).append(this.canvas, this.text);
    this.model.bind('change', this.render);
    this.preloadImages();
    this.render();
  },

  // Update the canvas to match file status and text with the current details.
  render: function() {
    this.updateCanvas();
    this.updateText();
  },

  // Updates the canvas to display either the upload progress, if currently
  // uploading, or one of our state indicators:
  // waiting, thinking, happy, or sad.
  updateCanvas: function() {
    switch (this.model.status()) {
    case 'queued'     : this.drawProgress(0);                     break;
    case 'uploading'  : this.drawProgress(this.model.progress()); break;
    case 'processing' : this.drawImage('thinking');               break;
    case 'done'       : this.drawImage('happy');                  break;
    case 'failed'     : this.drawImage('sad');                    break;
    }
  },

  // Updates the textual information to reflect the current state of our file.
  updateText: function() {
    this.text.html(this.textTemplate(this));
  },

  // Name value presented for textTemplate. Yes, our view class is also
  // acting as a presenter, deal with it.
  name: function() {
    return this.model.get('name');
  },

  // Summary value presented for textTemplate.
  summary: function() {
    switch (this.model.status()) {
    case 'queued'     : return 'Waiting…';
    case 'uploading'  : return this.progressSummary();
    case 'processing' : return 'Thinking…';
    case 'done'       : return 'Done!';
    case 'failed'     : return 'Failed'
    }
  },

  // Returns a nicely formatted '826KB of 3.2MB' style summary.
  progressSummary: function() {
    return humanFileSize(this.model.get('loaded')) + ' of ' +
           humanFileSize(this.model.get('total'));
  },

  // Draw progress pie.
  drawProgress: function(progress) {
    var ctx = this.canvas[0].getContext('2d'),
        t   = -Math.PI / 2,
        w   = 140,
        h   = 180,
        x   = 90,
        y   = 75,
        r   = 30,
        p   = 3;

    ctx.fillStyle = '#ddd';
    ctx.moveTo(0, 0);
    ctx.fillRect(0, 0, w, h);

    ctx.beginPath();
    ctx.fillStyle = '#838383';
    ctx.moveTo(x, y);
    ctx.arc(x, y, r, 0, Math.PI * 2, false);
    ctx.closePath();
    ctx.fill();

    ctx.beginPath();
    ctx.fillStyle = '#ddd';
    ctx.moveTo(x, y);

    if (progress < 1) var a = t - (Math.PI * 2 * (1 - progress));
                 else var a = t + (Math.PI * 2);

    ctx.arc(x, y, r - p, t, a, false);
    ctx.closePath();
    ctx.fill();
  },

  // Draw progress image. Available names are:
  // 'thinking', 'happy' & 'sad'.
  drawImage: function(name) {
    var ctx = this.canvas[0].getContext('2d');

    var img = new Image();

    img.onload = function() {
      ctx.fillStyle = '#ddd';
      ctx.moveTo(0, 0);
      ctx.fillRect(0, 0, 140, 180);
      ctx.moveTo(0, 0);
      ctx.drawImage(img, 0, 0);
    };

    img.src = this.imagePath({ name: name });
  },

  remove: function() {
    $(this.el).remove();
  },

  preloadImages: function() {
    _(['thinking', 'happy', 'sad']).each(_.bind(function(name) {
      var image = new Image();
      image.src = slices.UPLOAD_ICONS[name];
    }, this));
  }

});
