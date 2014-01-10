/*
 * # AutoScroll 1.1.1
 *
 * http://github.com/withassociates/autoscroll.js
 *
 * Simplest possible autoscrolling library.
 * Creates a top-level instance to start/stop the behaviour.
 *
 * ## Usage
 *
 *     window.autoscroll.start();
 *     window.autoscroll.stop();
 *
 * ## Settings & Defaults
 *
 *     window.autoscroll.interval     = 1000 / 60
 *     window.autoscroll.threshold    = 50
 *     window.autoscroll.velocity     = 2
 *     window.autoscroll.acceleration = 0.01
 *
 * ## Dependencies
 *
 *   * jQuery ~> 1.5.2
 *
 * ## Contributors
 *
 *   * jamie@withassociates.com
 *
 * Licensed under the terms of the MIT license.
 */

(function($) {

// class AutoScroll
var AutoScroll = function() {
  var self = this;
  self.version = '1.1.1';

  // starts autoscroll listening for events and performing scrolling
  self.start = function() {
    if (self.running) return;
    reset();
    listen();
    update();
    self.running = true;
  }

  // shuts down autoscroll
  self.stop = function() {
    if (!self.running) return;
    clearTimeout(timeout);
    stopListening();
    self.running = false;
  }

  // defaults
  self.interval     = 1000 / 60;
  self.threshold    = 50;
  self.velocity     = 2;
  self.acceleration = 0.01;

  // private properties
  var mouseNow,
      reset,
      scrollingUp,
      scrollingDown,
      timeout,
      viewportNow,
      pageNow,
      whenScrollingStarted,
      $window = $(window),
      $document = $(document);

  // private methods
  var checkTop,
      checkBottom,
      listen,
      stopListening,
      onMouseMove,
      onResize,
      update,
      velocity,
      triggerMouseMove;

  onMouseMove = function(event) {
    mouseNow = {
      pageX: event.pageX,
      pageY: event.pageY,
      x: event.pageX - $window.scrollLeft(),
      y: event.pageY - $window.scrollTop()
    };
  }

  onResize = function() {
    viewportNow = {
      width: $window.width(),
      height: $window.height()
    };
    pageNow = {
      width: $('body').outerWidth(),
      height: $('body').outerHeight()
    }
    $('body > *').each(function() {
      pageNow.height = Math.max(pageNow.height, $(this).outerHeight());
    });
  }

  checkTop = function() {
    var isPastThreshold = mouseNow.y < self.threshold,
        isAtMin = $window.scrollTop() <= 0;

    if (isPastThreshold && !isAtMin) {
      if (!scrollingUp) {
        scrollingUp = true;
        whenScrollingStarted = new Date();
      }
      var v = velocity();
      $window.scrollTop($window.scrollTop() - v);
      triggerMouseMove(0, -v);
    } else {
      scrollingUp = false;
    }
  }

  checkBottom = function() {
    var isPastThreshold = mouseNow.y > viewportNow.height - self.threshold,
        isAtMax = $window.scrollTop() >= pageNow.height - $window.height();

    if (isPastThreshold && !isAtMax) {
      if (!scrollingDown) {
        scrollingDown = true;
        whenScrollingStarted = new Date();
      }
      var v = velocity();
      $window.scrollTop($window.scrollTop() + v);
      triggerMouseMove(0, v);
    } else {
      scrollingDown = false;
    }
  }

  velocity = function() {
    var now  = new Date(),
        time = now - whenScrollingStarted;

    return Math.round(self.velocity + (self.acceleration * time));
  }

  triggerMouseMove = function(dx, dy) {
    $document.trigger($.Event('mousemove', {
      pageX: mouseNow.pageX + dx,
      pageY: mouseNow.pageY + dy
    }));
  }

  update = function() {
    if (mouseNow) {
      checkTop();
      checkBottom();
    }
    timeout = setTimeout(update, self.interval);
  }

  reset = function() {
    delete mouseNow;
    delete scrollingUp;
    delete scrollingDown;
    delete whenScrollingStarted;
  }

  listen = function() {
    $document.bind('mousemove', onMouseMove);
    $document.bind('resize', onResize);
    onResize();
  }

  stopListening = function() {
    $document.unbind('mousemove', onMouseMove);
    $document.unbind('resize', onResize);
  }

}

// Create top-level instance
// We don't want more than one, so we can lose the constructor after this.
window.autoscroll = new AutoScroll();

})(jQuery);
