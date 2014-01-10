(function($) {

$.fn.freezeHeight = function() {
  return this.each(function() {
    var $this = $(this);
    $this.height($this.height());
  });
}

$.fn.thawHeight = function() {
  return this.height('auto');
}

})(jQuery);
