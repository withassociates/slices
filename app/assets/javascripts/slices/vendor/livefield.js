/**
 * # Livefield.js
 *
 * http://github.com/withassociates/livefield.js
 *
 * A simple live-lookup ui library.
 *
 * ## Usage
 *
 * As a basic use case, let's say we have an input in a cms that lets users
 * specify which page a thumbnail ought to link to.
 *
 * We have an action on the server `/pages/search` that will find matching
 * pages and return them as JSON.
 *
 * This is how we'd implement livefield:
 *
 *     <!-- input to bind to -->
 *     <input
 *       type="text"
 *       name="link_path"
 *       id="my-input"
 *       data-store="/pages/search/{{query}}"
 *       data-template="#link-template"
 *     />
 *
 *     <!-- template for result options -->
 *     <script type="template/handlebars" id="link-template">
 *       <li data-value="{{path}}">
 *         <span class="name">{{name}}</span>
 *         <span class="path">{{path}}</span>
 *       </li>
 *     </script>
 *
 *     <!-- and activate livefield -->
 *     <script>
 *       $('#my-input').livefield();
 *     </script>
 *
 * ### Data-store
 *
 * Your input needs `data-store` to specify the lookup URL. This can be
 * plain text or a handlebars template. If it's a template, it will
 * receive just the `query` paramters.
 *
 * ### Data-template
 *
 * Your input also needs `data-template`. This should be a jQuery-compatible
 * selector for the element containing the template. Typically, this will
 * be in a `script` tag as in the example above.
 *
 * ### Data-value
 *
 * Your result option template needs to have the `data-value` option.
 * The value of this attribute will be used to populate your input.
 *
 * ## Dependencies
 *
 * * [jQuery](http://jquery.com/) ~> 1.5
 * * [Handlebars](http://handlebars.strobeapp.com/) ~> 1.0
 *
 * ## Contributors
 *
 * * jamie@withassociates.com
 *
 * ## License
 *
 * (The MIT License)
 *
 * Copyright (c) 2011 With Associates
 *
 * Permission is hereby granted, free of charge, to any person obtaining
 * a copy of this software and associated documentation files (the
 * 'Software'), to deal in the Software without restriction, including
 * without limitation the rights to use, copy, modify, merge, publish,
 * distribute, sublicense, and/or sell copies of the Software, and to
 * permit persons to whom the Software is furnished to do so, subject to
 * the following conditions:
 *
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
 * IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
 * CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
 * TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
 * SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 *
 */

(function($, window) {

// module Livefield
var Livefield = { VERSION: '0.11.0' };

// class Livefield.Controller
Livefield.Controller = function(options) {
  var self = this;

  // constants
  var KEY_ESC   = 27,
      KEY_UP    = 38,
      KEY_DOWN  = 40,
      KEY_ENTER = 13;
      DEFAULT_TEMPLATE = '<li class="livefield-result" data-value="{{value}}">{{name}}</li>';

  // views
  var $input,
      $results,
      template,
      savedVal;

  // -- SETUP --

  function setup() {
    $input = $(options.input);
    self.store = new Livefield.Store({
      url: options.store || $input.attr('data-store')
    });
    setupInput();
    setupStore();
    setupTemplate();
    setupBindings();
  }

  function setupInput() {
    $input.addClass('livefield-input');
  }

  function setupStore() {
    self.store = new Livefield.Store({
      url: options.store || $input.attr('data-store')
    });
  }

  function setupTemplate() {
    var $template = $($input.attr('data-template') || DEFAULT_TEMPLATE);
    template = Handlebars.compile($template.html());
  }

  function setupBindings() {
    $input.bind('keydown keypress', onKeyDown);
    $input.bind('focus', onFocus);
    $input.bind('blur', onBlur);
  }

  // -- ACTIONS --

  function update() {
    if (hasValue()) {
      find();
    } else {
      updateResults([]);
    }
  }

  function find() {
    self.store.find(value(), onFindComplete);
  }

  function updateResults(results) {
    if (results.length === 0) {
      removeResults();
    } else {
      savedVal = value();
      appendResults();
      $results.html('');
      for (var i in results) {
        var result = results[i];
        var $result = $(template(result));
        $result.addClass('livefield-result');
        $result.appendTo($results);
      }
      positionResults();
    }
  }

  function updateValue() {
    if (!$results) return;

    var $chosen = $results.find('.livefield-highlighted').first();
    if ($chosen.length > 0) {
      if (savedVal == null) savedVal = $input.val();
      $input.val($chosen.attr('data-value'));
    } else {
      if (savedVal) {
        $input.val(savedVal);
        savedVal = null;
      }
    }
  }

  function commit() {
    $input.blur();
    removeResults();
    $input.trigger('change');
  }

  // -- HELPERS --

  function value() {
    return $input.val();
  }

  function hasValue() {
    return value() != '';
  }

  function appendResults() {
    if (!$results) {
      $results = $('<ul class="livefield-results" />').
        delegate('.livefield-result', 'mouseout', onMouseOut).
        delegate('.livefield-result', 'mouseover', onMouseOver).
        delegate('.livefield-result', 'mousedown', onMouseDown).
        appendTo('body');
      positionResults();
      $(window).bind('resize', positionResults);
    }
  }

  function positionResults() {
    var padding       = $results.outerWidth() - $results.innerWidth(),
        resultsHeight = $results.outerHeight();

    $results.hide();

    var bodyHeight    = $('body').height(),
        inputTop      = $input.offset().top,
        inputHeight   = $input.outerHeight(),
        inputBottom   = inputTop + inputHeight,
        hasSpaceBelow = (bodyHeight - inputTop > resultsHeight),
        hasSpaceAbove = (inputTop > resultsHeight);

    if (hasSpaceBelow || !hasSpaceAbove) {
      var top = inputBottom;
      $results.removeClass('livefield-drop-up');
    } else {
      var top = inputTop - resultsHeight;
      $results.addClass('livefield-drop-up');
    }

    $results.css({
      position : 'absolute',
      zIndex   : '1000',
      width    : ($input.outerWidth() - padding) + 'px',
      left     : $input.offset().left + 'px',
      top      : top + 'px'
    }).show();
  }

  function removeResults() {
    if ($results) {
      $results.remove();
      $results = null;
      $(window).unbind('resize', positionResults);
    }
  }

  function highlightResult(which) {
    var dropUpMode = $results && $results.hasClass('livefield-drop-up');

    switch (which) {
    case 'none':
      $results.find('.livefield-highlighted').
        removeClass('livefield-highlighted');
      break;
    case 'next':
      var $current = $results.find('.livefield-highlighted');
      var $next;

      if ($current.length > 0) {
        $next = $current.next();
      } else if (!dropUpMode) {
        $next = $results.find('.livefield-result:first-child');
      }

      if ($next && $next.length > 0) {
        $current.removeClass('livefield-highlighted');
        $next.addClass('livefield-highlighted');
      } else if (dropUpMode) {
        $current.removeClass('livefield-highlighted');
      }
      break;
    case 'prev':
      var $current = $results.find('.livefield-highlighted');
      var $prev;

      if ($current.length > 0) {
        $prev = $current.prev();
      } else if (dropUpMode) {
        $prev = $results.find('.livefield-result:last-child');
      }

      if ($prev && $prev.length > 0) {
        $current.removeClass('livefield-highlighted');
        $prev.addClass('livefield-highlighted');
      } else if (!dropUpMode) {
        $current.removeClass('livefield-highlighted');
      }
      break;
    default:
      var $current = $results.find('.livefield-highlighted');
      var $chosen = $(which);
      $current.removeClass('livefield-highlighted');
      $chosen.addClass('livefield-highlighted');
    }
  }

  // -- EVENT HANDLERS --

  function onKeyDown(event) {
    if (event.which === KEY_DOWN && $results) {
      event.preventDefault();
      highlightResult('next');
      updateValue();
      return;
    }

    if (event.which === KEY_UP && $results) {
      event.preventDefault();
      highlightResult('prev');
      updateValue();
      return;
    }

    if (event.which === KEY_ENTER) {
      event.preventDefault();
      commit();
      return;
    }

    if (event.which === KEY_ESC) {
      $input.val('');
    }

    self.store.stop();
    setTimeout(update, 0); // deferred
  }

  function onMouseOver(event) {
    highlightResult(this);
    updateValue();
  }

  function onMouseOut(event) {
    highlightResult('none');
    updateValue();
  }

  function onMouseDown(event) {
    highlightResult(this);
    updateValue();
    commit();
  }

  function onFocus(event) {
    updateValue();
    update();
    setTimeout(function() {
      $input.select();
    }, 0);
  }

  function onBlur(event) {
    removeResults();
  }

  function onFindComplete(results) {
    updateResults(results);
  }

  // -- RUN --

  setup();
}

// class Livefield.Store
Livefield.Store = function(options) {
  var self = this;

  var MAX_QUEUE_LENGTH = 1;

  var transport,
      urlTemplate,
      cache = {};

  self.find = function(query, callback) {
    self.stop();
    self.queue.push([query, callback]);
    while (self.queue.length > MAX_QUEUE_LENGTH) self.queue.shift();
    if (!self.busy) nextInQueue();
  }

  self.stop = function() {
    if (transport) {
      transport.abort();
      transport = null;
    }
    self.busy = false;
  }

  function nextInQueue() {
    if (self.queue.length === 0) return;

    self.busy = true;

    var args     = self.queue.shift(),
        query    = args[0].replace(/\/+/g, ' '),
        callback = args[1];
        url      = urlTemplate.replace(':query', query);

    if (cache[url]) {
      onSuccess(url, callback);
    } else {
      transport = $.getJSON(url).then(function(data) {
        if (!self.busy) return;
        transport = null;
        cache[url] = data;
        onSuccess(url, callback);
      }, onFail);
    }
  }

  function onSuccess(url, callback) {
    callback(cache[url]);
    self.busy = false;
    nextInQueue();
  }

  function onFail() { // TODO
    // $.error('Store failed to fetch data');
    // transport = null;
    // if (self.busy) {
    //   self.busy = false;
    //   nextInQueue();
    // }
  }

  function setup() {
    urlTemplate = options.url;
    self.queue = [];
  }

  setup();
}

// jQuery plugin
$.fn.livefield = function(options) {
  return this.each(function() {
    new Livefield.Controller($.extend(options, { input: this }));
  });
}

// Make module globally available
window.Livefield = Livefield;

})(jQuery, window);
