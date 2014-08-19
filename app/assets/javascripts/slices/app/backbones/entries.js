var EntriesBackbone = $.extend(true, {}, GenericBackbone, {
  collection_prototype: {
    page_id: '',
    search_url: '',
    search_data: function() {
      return { search: this.search_term, page: this.page }
    },

    initialize: function(models, options) {
      this.page_id = options.page_id;
      this.search_url = '/admin/pages/' + this.page_id + '/entries';
    }
  },

  model_prototype: {
    for_template: function() {
      return this.toJSON();
    },

    url: function() {
      return this.get('url');
    }

  },

  view_prototype: {
     events: {
      "click a.delete": "clear_with_confirmation"
    },

    tagName: 'tr',

    clear_with_confirmation: function() {
      var confirmed = confirm('Are you sure?');
      if (confirmed) this.model.clear();
    }
  },

  app_view_prototype: {
    events: {
      "click #pagination a": "paginate",
      "keyup #entries-search": "call_search",
      "click #add-entry": "add_entry"
    },

    setup_search: function() {
      var self = this;
      setInterval(function() {
        if ( self.search_now ) {
          self.search_now = false;
          var search_length = self.$search_box.val().length;
          if ((search_length > 2) || (search_length === 0)) {
            self.collection.page = 1;
            self.search();
          }
        }
      }, 450);
    },

    initialize: function(options) {
      this.collection = this.options.collection;
      this.view_prototype = this.options.view_prototype;
      _.bindAll(this, "render", "set_view_template");
      this.collection.bind('reset', this.set_view_template);
      this.collection.bind('reset', this.render);
      this.$search_box = this.$('#entries-search');
      this.setup_search();
      this.search();

      if (options.sort_field === 'position') {
        var that = this;
        this.$('tbody').sortable({
          update: function() { that.update_on_sort(); }
        });
      }

    },

    set_view_template: function() {
      if(this.collection.models.length == 0) {
        attributes = {};
      } else {
        attributes = this.collection.models[0].attributes;
      }
      var fields = _.chain(attributes).
                     keys().
                     reject(function(key) { return key.indexOf('_') === 0 }).
                     value();

      fields = _.map(fields, function(key) {
        return slices.entryTemplate(key);
      });

      fields.push("<td><a href='#' class='delete'>Delete</a></td>");

      var template = Handlebars.compile(fields.join(''));
      this.view_prototype = this.view_prototype.extend({template: template});
      this.collection.unbind('reset', this.set_view_template);
    },

    render: function() {
      var view_prototype = this.view_prototype;
      this.$('#entries-list tbody').empty();
      _.each(this.collection.models, function(entry) {
        var view = new view_prototype({model: entry}),
            $view = $(view.render().el);

        $view.data('model', entry);

        self.$("#entries-list tbody").append($view);
      });
      this.render_pagination();
    },

    add_entry: function(event) {
      var button = $(event.target);

      $('#general-modal').jqm({
        ajax: button.attr('href'),
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
    },

    update_on_sort: function() {
      var parent = { id: this.collection.page_id };

      parent.children = this.$('#entries-list tbody tr').map(function() {
        return { id: $(this).data('model').id };
      }).toArray();

      $.ajax({
        url: '/admin/site_maps/update',
        type: 'PUT',
        data: JSON.stringify({ sitemap: [parent] }),
        contentType: 'application/json',
        dataType: 'json'
      });
    }

  },

  bind_prototypes: function() {
    this.collection_prototype = Backbone.Collection.extend(this.collection_prototype);
    this.view_prototype = Backbone.View.extend(this.view_prototype);
    this.model_prototype = Backbone.Model.extend(this.model_prototype);
    this.app_view_prototype.el = $('#container');
    this.app_view_prototype = Backbone.View.extend(this.app_view_prototype);
  },

  boot: function(page_id, options) {
    this.bind_prototypes();
    this.collection = new this.collection_prototype(null, {page_id: page_id});
    this.collection.model = this.model_prototype;
    this.app_view = new this.app_view_prototype($.extend({}, options, {
      collection: this.collection,
      view_prototype: this.view_prototype
    }));
  }

});
