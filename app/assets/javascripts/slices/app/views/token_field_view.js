(function() {

// Tokenized field, used for tags, categories etc.
//
// This shouldn’t be instantiated directly.
// Instead, use `{{tokenField}}` like this:
//
//     {{tokenField field="categories" options="available_categories"}}
//

var ESC       = 27,
    ENTER     = 13,
    BACKSPACE = 8,
    UP        = 38,
    DOWN      = 40,
    COMMA     = 188,
    TAB       = 9;

slices.TokenFieldView = Backbone.View.extend({

  // -- Config --

  events: {
    'keydown'       : 'onKey',
    'keypress'      : 'onKey',
    'click .del'    : 'onClickDel',
    'click .option' : 'onClickOption',
    'click'         : 'onClick'
  },

  className: 'token-field',

  template: Handlebars.compile(
    '<input type="text" class="input" name="{{id}}">' +
    '<span class="tokens">' +
      '{{#each values}}' +
        '<span class="token" data-value="{{this}}" unselectable="true">{{this}} <span class="del">&times;</span></span>' +
      '{{/each}}' +
    '</span>' +
    '<span class="options">' +
      '{{#each valueOptions}}' +
        '<a href="#" class="option">{{this}}</a>' +
      '{{/each}}' +
    '</span>'
  ),

  // -- Init --

  initialize: function() {
    _.bindAll(this);

    this.values = this.sanitizeValues(this.options.values);
    this.prevValues = [].concat(this.values || []);
    this.valueOptions = [].concat(this.options.options || []);

    $(document).on('slices:willSubmit', this.capture);

    if (this.options.autoAttach) _.defer(this.attach);
  },

  // -- Rendering --

  placeholder: function() {
    return Handlebars.compile('<div id="placeholder-{{id}}"></div>')(this);
  },

  attach: function() {
    $('#placeholder-' + this.id).replaceWith(this.el);
    this.render();
  },

  render: function() {
    this.prepareValueOptions();

    this.$el.html(this.template(this));

    this.updateComputedValue();
    this.updateValueOptions();
    this.updateLayout();
    this.updateInput();

    if (_.isEqual(this.values, this.prevValues)) return;

    this.$el.find('input').trigger('change');
    this.prevValues = [].concat(this.values);
  },

  // -- Commands --

  focus: function() {
    this.$el.find('input').focus();
  },

  capture: function() {
    var newValues = this.$el.find('input').val().split(/ *, */);

    this.values = this.sanitizeValues(this.values.concat(newValues));

    this.render();
    this.focus();
  },

  delayedCapture: _.debounce(function() {
    this.capture();
  }, 1500),

  focusOrRemoveLastToken: function(e) {
    var focusedToken = this.$el.find('.token.focus');

    if (focusedToken.length) {
      this.values.pop();
      this.render();
      this.focus();
    } else {
      this.$el.find('.token:last').addClass('focus');
    }
  },

  updateLayout: function() {
    var tokens = this.$el.find('.tokens'),
        input = this.$el.find('input'),
        lastToken = tokens.children().last();


    if (!this.hasOwnProperty('_paddingLeft')) {
      this._paddingLeft = parseInt(input.css('paddingLeft'));
    }

    if (this.values.length) {
      var left = lastToken.position().left + lastToken.outerWidth();
      input.css({ paddingLeft: left + this._paddingLeft });
    } else {
      input.css({ paddingLeft: this._paddingLeft });
    }

    if (tokens.outerHeight() > input.outerHeight()) {
      input.css({
        height: tokens.outerHeight(),
        paddingTop: tokens.outerHeight() - lastToken.outerHeight()
      });
    }
  },

  updateInput: function() {
    if (this.options.singular && this.values.length) {
      this.$el.find('input').attr('disabled', true);
    }
  },

  updateValueOptions: function() {
    var self = this;

    this.$el.find('.option').each(function() {
      var option = $(this),
          value = option.text();

      if (_.contains(self.values, value)) {
        $(this).addClass('used');
      } else {
        $(this).removeClass('used');
      }
    });
  },

  updateComputedValue: function() {
    if (this.options.singular) {
      var computedValue = this.values[0];
    } else {
      var computedValue = this.values;
    }

    this.$el.data('computed-value', computedValue || null);
  },

  // -- Event Handlers --

  onKey: function(e) {
    switch (e.which) {
    case ENTER:
    case COMMA:
    case TAB:
      this.onTokenBreaker(e); break;
    case BACKSPACE:
      this.onBackspace(e); break;
    default:
      this.delayedCapture();
    }
  },

  onTokenBreaker: function(e) {
    var input = this.$el.find('input'),
        value = input.val();

    if (value.length) {
      e.preventDefault();
      this.capture();
    }
  },

  onBackspace: function(e) {
    var input = this.$el.find('input'),
        value = input.val();

    if (value.length) {
      this.delayedCapture();
    } else {
      e.preventDefault();
      this.focusOrRemoveLastToken();
    }
  },

  onClick: function(e) {
    this.render();
    this.focus();
  },

  onClickDel: function(e) {
    e.preventDefault();

    var token = $(e.target).closest('.token'),
        value = token.data('value');

    this.values = _.without(this.values, value);
    this.render();
    this.focus();
  },

  onClickOption: function(e) {
    e.preventDefault();

    var option = $(e.target),
        value = option.text();

    if (this.options.singular) {
      this.values = [value];
    } else {
      if (_.contains(this.values, value)) {
        this.values = _.without(this.values, value);
      } else {
        this.values.push(value);
      }
    }

    this.render();
  },

  // -- Helpers --

  sanitizeValues: function(values) {
    values = [values];
    values = _.flatten(values);
    values = _.map(values, function(token) {
      return token && token.replace(/^\s+/, '').replace(/\s+$/, '');
    });
    values = _.compact(values);
    values = _.uniq(values);

    if (this.options.singular) values = values.slice(0, 1);

    return values;
  },

  prepareValueOptions: function() {
    this.valueOptions = _.uniq(this.valueOptions.concat(this.values)).sort();
  }

});

})();
