// Date field
//
// This shouldn’t be instantiated directly.
// Instead, use `{{dateField}}` like this:
//
//     {{dateField field="example"}}
//
slices.DateFieldView = Backbone.View.extend({

  // -- Config --

  events: {
    'click .calendar-button' : 'onClickCalendar',
    'click .clear'           : 'onClickClear',
    'change select'          : 'onSelectTime'
  },

  className: 'date-field',

  template: Handlebars.compile(
    '<span class="display">' +
      '{{{display}}}' +
    '</span>' +
    '<button class="calendar-button">Choose Date</button>' +
    '<button class="clear">&times;</button>'
  ),

  displayTemplate: Handlebars.compile(
    '<span class="date">{{date}} at</span> ' +
    '<select class="hour">' +
      '{{#each hours}}<option {{attrs}}>{{value}}</option>{{/each}}' +
    '</select>' +
    ' : ' +
    '<select class="minute">' +
      '{{#each minutes}}<option {{attrs}}>{{value}}</option>{{/each}}' +
    '</select>'
  ),

  // -- Init --

  initialize: function() {
    _.bindAll(this);
    this.options.value = this.options.value || null;
    this.value = moment(this.options.value);
    this.prevValue = moment(this.value);
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
    this.$el.attr('name', this.options.name);
    this.$el.html(this.template(this));
    this.updateComputedValue();
    this.updateUI();
    this.updateCalendar();

    if (this.valueHasChanged()) {
      this.prevValue = moment(this.value);
      this.$el.trigger('change');
    }

    return this;
  },

  display: function() {
    if (this.value) {
      var self = this;
      return this.displayTemplate({
        date: this.value.format('dddd D MMMM YYYY'),
        hours: _.map(_.range(0, 24), function(hour) {
          var o = { value: _.string.pad('' + hour, 2, '0') };
          if (hour == self.value.hours()) o.attrs = 'selected';
          return o;
        }),
        minutes: _.map(_.range(0, 60, 15), function(minute) {
          var o = { value: _.string.pad('' + minute, 2, '0') };
          if (minute == self.value.minutes()) o.attrs = 'selected';
          return o;
        })
      });
    } else {
      return 'No date set';
    }
  },

  // -- Event Handlers --

  onClickCalendar: function(event) {
    event.preventDefault();
    event.stopImmediatePropagation();
    this.toggleCalendar();
  },

  onClickClear: function(event) {
    event.preventDefault();
    event.stopImmediatePropagation();
    this.value = null;
    this.render();
  },

  onCalendarChange: function() {
    this.value = moment(this.calendar().value);
    this.render();
  },

  onSelectTime: function() {
    var hour = parseInt(this.$el.find('.hour').val(), 10),
        minute = parseInt(this.$el.find('.minute').val(), 10);

    this.value.hours(hour).minutes(minute);
    this.render();
  },

  // -- Actions --

  updateComputedValue: function() {
    var computedValue = this.value && this.value.toDate() || null;
    this.$el.data('computed-value', computedValue);
  },

  updateUI: function() {
    if (this.value) {
      this.$el.find('.clear').show();
    } else {
      this.$el.find('.clear').hide();
    }
  },

  showCalendar: function() {
    this.calendar().show();
  },

  hideCalendar: function() {
    this.calendar().hide();
  },

  toggleCalendar: function() {
    this.calendar().toggle();
  },

  updateCalendar: function() {
    this.calendar().anchor = this.$el.find('.calendar-button');
    this.calendar().setValue(this.value);
  },

  // -- Helpers --

  calendar: function() {
    if (!this._calendar) {
      this._calendar = new slices.CalendarView({
        value: this.value,
        onChange: this.onCalendarChange
      });
    }
    return this._calendar;
  },

  valueHasChanged: function() {
    return !this.valueHasNotChanged();
  },

  valueHasNotChanged: function() {
    return (this.value == null && this.prevValue == null) ||
           (this.value && this.value.is(this.prevValue));
  }

});
