$(function() {
  $('#children').on('change', function(e) {
    e.preventDefault();
    e.stopPropagation();

    var val = $(this).val();

    $(this).find('option:selected').removeAttr('selected');
    $(this).find('option:first').attr('selected', 'selected');

    if (val.match(/pages\/new/)) {
      $('#general-modal').jqm({
        ajax: val,
        modal: false,
        onHide: function (h) {
          h.w.fadeOut(100);
          h.o.fadeOut(100);
        },
        onShow: function (h) {},
        onLoad: function (h) {
          h.w.fadeIn(50);
          h.o.fadeIn(100);
        },
        overlay: 40
      }).jqmShow();
    } else if (val.length > 0) {
      window.location.pathname = val;
    }
  });
});
