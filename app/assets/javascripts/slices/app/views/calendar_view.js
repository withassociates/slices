// Calendar View
slices.CalendarView = Backbone.View.extend({

  // -- Config --

  events: {
    'click [data-action="hide"]'       : 'hide',
    'click [data-action="prev-month"]' : 'prevMonth',
    'click [data-action="next-month"]' : 'nextMonth',
    'mousedown time'                   : 'onClickDay'
  },

  className: 'calendar-modal',

  template: Handlebars.compile(
    '<span class="background" data-action="hide"></span>' +
    '<div class="calendar">' +
      '<table>' +
        '<thead>' +
          '<tr>' +
            '<td data-action="prev-month">&larr;</td>' +
            '<th class="month" colspan="5">{{monthName}}</th>' +
            '<td data-action="next-month">&rarr;</td>' +
          '</tr>' +
          '<tr>' +
            '<th class="weekday">M</th>' +
            '<th class="weekday">T</th>' +
            '<th class="weekday">W</th>' +
            '<th class="weekday">T</th>' +
            '<th class="weekday">F</th>' +
            '<th class="weekday">S</th>' +
            '<th class="weekday">S</th>' +
          '</tr>' +
        '</thead>' +
        '<tbody>{{{body}}}</tbody>' +
      '</table>' +
    '</div>'
  ),

  bodyTemplate: Handlebars.compile(
    '{{#each this}}' +
      '<tr>' +
        '{{#each this}}' +
          '<td>' +
            '<time class="{{klass}}" datetime="{{value}}">' +
              '{{date}}' +
            '</time>' +
          '</td>' +
        '{{/each}}' +
      '</tr>' +
    '{{/each}}'
  ),

  // -- Init --

  initialize: function() {
    _.bindAll(this);

    $(document).on('slices:willSubmit', this.remove);

    this.setValue(this.options.value);

    this.$el.appendTo('body');
    this.$el.attr('data-state', 'preparing');
    this.$el.hide();
  },

  // -- Rendering --

  render: function() {
    this.$el.html(this.template(this));
    this.updatePosition();
    return this;
  },

  body: function() {
    var data        = [],
        today       = moment().startOf('day'),
        thisMonth   = this.month.clone(),
        nextMonth   = thisMonth.clone().add('months', 1),
        firstMonday = thisMonth.clone().day(1),
        finalSunday = nextMonth.clone().day(7),
        date        = firstMonday.clone();

    while (date <= finalSunday) {
      if (date.day() === 1) data.push([]);

      var obj = {
        date  : date.date(),
        value : date.format(),
        klass : []
      };

           if (date.is(today)) obj.klass.push('today');
      else if (date < thisMonth) obj.klass.push('prev-month');
      else if (date >= nextMonth) obj.klass.push('next-month');

      if (this.value) {
        if (date.is(this.value.clone().startOf('day'))) obj.klass.push('highlight');
      }

      obj.klass = obj.klass.join(' ');

      data[data.length - 1].push(obj);

      date.add('days', 1);
    }

    return this.bodyTemplate(data);
  },

  monthName: function() {
    return this.month.format('MMMM YYYY');
  },

  // -- Event Handlers --

  onClickDay: function(event) {
    var day = $(event.target),
        value = moment(day.attr('datetime'));

    if (this.value) {
      value.hours(this.value.hours()).minutes(this.value.minutes());
    }

    this.setValue(value);
    this.render();
    this.options.onChange && this.options.onChange();
  },

  // -- Actions --

  show: function() {
    this.resetMonth();
    this.$el.show();
    this.render();
    this.updatePosition();
    this.$el.attr('data-state', 'showing');
  },

  hide: function() {
    this.$el.attr('data-state', 'hiding');

    var self = this;
    setTimeout(function() { self.$el.hide() }, 250);
  },

  toggle: function() {
    switch (this.$el.data('state')) {
    case 'preparing':
    case 'hiding':
      this.show(); break;
    case 'showing':
      this.hide(); break;
    }
  },

  prevMonth: function() {
    this.month.subtract('months', 1);
    this.render();
  },

  nextMonth: function() {
    this.month.add('months', 1);
    this.render();
  },

  setValue: function(newValue) {
    this.value = moment(newValue);
    this.resetMonth();
  },

  resetMonth: function() {
    this.month = (this.value || moment()).clone().startOf('month');
  },

  remove: function() {
    this.$el.remove();
  },

  // -- Helpers --

  updatePosition: function() {
    var calendar = this.$el.find('.calendar'),
        anchor = this.anchor,
        offset = anchor.offset();

    offset.top += anchor.outerHeight();
    offset.top = offset.top + 'px';

    offset.left += anchor.outerWidth() / 2;
    offset.left -= calendar.outerWidth() / 2;
    offset.left = offset.left + 'px';

    calendar.css(offset);
  }

});
