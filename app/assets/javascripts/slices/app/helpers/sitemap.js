$(function () {

  var KEY_ESC = 27;

  var locked = true;

  function serialiseSitemap(ul) {
    var children = [];
    ul.find('>li:not(.set-link)').each(

      function () {
        var li = $(this);
        var item = { id: li.attr('rel') }
        var childHolder = li.find('>ol');
        if (childHolder.length && childHolder.find('>li:not(.set-link)').length) {
          item.children = serialiseSitemap(childHolder);
        }
        children.push(item);
      }
    );
    return children;
  }

  function filterSitemap(needle){

    var show = [];
    var hide = [];

    $('#sitemap li h2, #virtual-pages li h2').each(function(){
      if ($(this).text().search(new RegExp(needle, "i")) > -1) {
        show.push( $(this).closest('li')[0] );
      } else {
        hide.push( $(this).closest('li')[0] );
      }
    });

    $(hide).find('div').hide();
    $(show).find('div').show();

  }

  var searchField = $('#sitemap-search');

  if (searchField.length) {

    searchField.on('keyup click', function(event) {
      // ESC key handing
      if (event.which === KEY_ESC) {
        if ($(this).val() !== '') {
          $(this).val('');
        } else {
          $(this).blur();
          return;
        }
      }

      filterSitemap($(this).val());
    });

    // Cmd/ctrl + F focuses the search field.
    $(document).on('keypress', function(event) {
      if (
        (event.which === 102 && event.metaKey) || // cmd + F
        (event.which === 6 && event.ctrlKey) // ctrl + F
      ) {
        event.preventDefault();
        searchField.focus();
      }
    });

  }

  $('#sitemap-form').bind('submit', function (e) {
    if (locked) { return false; }
    var sitemap = serialiseSitemap($('#sitemap'));
    $.ajax({
      url: '/admin/site_maps/update',
      type: 'PUT',
      data: JSON.stringify({ sitemap: sitemap }),
      contentType: 'application/json',
      dataType: 'json',
      success: function (data, statusText, xhr) {
        // TODO:
      },
      error: function (xhr, textStatus, errorThrown) {
        // TODO:
      }
    });
    return false;
  });

  $('.add-child').bind('click', function () {
    $('#general-modal').jqm({
      ajax: this.href,
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
    return false;
  });

  $('a.delete').toggle();
  $('#structure-locked a').bind('click', function() {
    locked = !locked;
    $('#sitemap').toggleClass('unlocked');
    $('#structure-locked, #structure-unlocked').toggle();
    $('a.delete').toggle();
    if (!locked) {
      $('html').addClass('sitemap-unlocked');
    } else {
      $('html').removeClass('sitemap-unlocked');
    }

    $sitemap = $('#sitemap > li > ol');
    $sitemap.nestedSortable({
      forcePlaceholderSize : true,
      toleranceElement     : '> div',
      disableNesting       : 'no-nest',
      placeholder          : 'placeholder',
      errorClass           : 'nested-error',
      tolerance            : 'pointer',
      tabSize              : 25,
      opacity              : 0.6,
      scroll               : false,
      handle               : 'div',
      items                : 'li',

      beforeStart: function() {
        $sitemap.freezeHeight();
        window.autoscroll.start();
      },
      stop: function() {
        $sitemap.thawHeight();
        window.autoscroll.stop();
      }
    });

    return false;
  });

});

