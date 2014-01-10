// File to keep the simpler abstracted visual plugins seperate from the rest of the code...
window.log = function(){
  log.history = log.history || [];   // store logs to an array for reference
  log.history.push(arguments);
  if(this.console) {
    console.log( Array.prototype.slice.call(arguments) );
  }
};

// simple editinplace functionality
(function ($, window, undefined) {

  // Shows a message whenever an ajax communication to the server is occuring...
  $(function () {
    var sc = $('#server-communication').ajaxStart(

    function () {
      sc.show();
    }).ajaxStop(

    function () {
      sc.hide();
    });
  });
  // Loops over all eligible items [selects, checkboxes and radio buttons] within the called on element and sets their
  // state to represent the contents of their data-value attribute
  $.fn.applyDataValues = function () {
    this.find('select').each(function () {
      var select = $(this);
      var selectedValue = select.data('value');
      select.find('option[value="' + selectedValue + '"]').attr('selected', 'selected');
      select.val(selectedValue);
    });

    this.find(':checkbox').each(function () {
      var cb = $(this);
      if (cb.data('value') == 'true' || cb.data('value') == '1') {
        cb.attr('checked', 'checked');
      }
    });

    this.find(':radio').each(function () {
      var rad = $(this),
          parent = rad.closest('[data-value]'),
          selectedValue = parent.data('value');

      if (rad.val() == selectedValue) rad.attr('checked', 'checked');
    });

    return this;
  }

  // Implements edit in place functionality...
  $.fn.editinplace = function (settings) {
    this.find('textarea,input[type=text]').each(
    function () {
      var ta = $(this);
      var val = ta.val();
      ta.after(
      $('<span />').attr({
        'class': ta.attr('class')
      }).text(val)).remove();
    });
    this.find('.editinplace').bind('click', function () {
      var span = $(this),
        val = span.text()
        inp = $(span.is('.long') ? '<textarea id="editing-in-place" />' : '<input id="editing-in-place" type="text" />')
          .val(val).
          focus()
          .bind('keydown', function (e) {
            // Need to capture enter so that if somebody presses return and submits the
            // form then we blur first and the updated value is submitted...
            var keyCode = (window.event) ? e.which : e.keyCode;
            if (keyCode === 13) {
              var f = this.form;
              $(this).blur();
              $(f).trigger('submit');
            }
          })
          .bind('blur', function () {
            var inp = $(this);
            span.text(inp.val()).show();
            inp.remove();
          });
        if (span.siblings('label').length == 1) {
          inp.attr('name', span.siblings('label').attr('for'))
        }
      span.after(inp).hide();
      inp.focus();
    });
  }

  $.fn.initDataPlugins = function() {
    this.find('[data-plugin]').each(function() {
      var e = $(this), plugin = e.attr('data-plugin');
      if (_.isFunction(e[plugin])) e[plugin]();
    });
    return this;
  }

})(jQuery, this);
