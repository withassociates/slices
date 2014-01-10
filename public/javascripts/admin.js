var LunchPicker = {
  run: function(target) {
    $(target).change(function(e) {
      $(target).siblings('.lunch-comment').text('Good choice');
    });
  }
}

// jQuery plugin
$.fn.lunchPicker = function(options) {
  return this.each(function() {
    LunchPicker.run(this);
  });
}

