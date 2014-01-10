$(function() {

  $(window).scroll(function() {
    if ($(window).scrollTop() >= 40) {
      $('#container-actions').css({
        position : 'fixed',
        top      : '0',
        width    : '100%'
      });
    } else {
      $('#container-actions').css({
        position : 'absolute',
        top      : '40px',
        width    : '100%'
      });
    }
  });

});

