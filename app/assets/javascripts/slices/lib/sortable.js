/*
 * Patch for sortable and nestedSortable scroll jump issue
 */

(function($) {

  var superMouseStart = $.ui.sortable.prototype._mouseStart;
  $.ui.sortable.prototype._superMouseStart = superMouseStart;
  $.ui.sortable.prototype._mouseStart = function(event, overrideHandle, noActivation) {
    this._trigger("beforeStart", event, this._uiHash());
    this._superMouseStart(event, overrideHandle, noActivation);
  }

})(jQuery);
