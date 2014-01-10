var AdminsBackbone = $.extend(true, {}, GenericBackbone, {
  collection_prototype: {
    page_id: '',
    search_url: '',
    search_data: function() {
      return { search: this.search_term, page: this.page }
    },

    initialize: function(models, options) {
      this.page_id = options.page_id;
      this.search_url = '/admin/admins';
    }
  },

  model_prototype: {
    for_template: function() {
      var obj = this.toJSON();
      obj.url = this.url();
      return obj;
    },

    initialize: function() {
      if (!this.get('last_sign_in_at')) {
        this.set({'last_sign_in_at': 'never'});
      }
      if (!this.get('name')) {
        this.set({'name': 'No Name Set'});
      }
    },

    url: function() {
      return "/admin/admins/" + this.id;
    }

  },

  view_prototype: {
     events: {
      "click a.delete": "clear"
    },

    tagName: 'tr',

    template: Handlebars.compile(
        "<td class='name'><a href='{{url}}'>{{name}}</a></td>" +
        "<td class='email'>{{email}}</td>" +
        "<td class='login'>{{last_sign_in_at}}</td>" +
        "<td>{{#if current_admin}}This is you{{else}}<a href='#' class='delete'>Delete</a>{{/if}}</td>"
        ),
  },

  app_view_prototype: {
    events: {
      "click #pagination a": "paginate",
      "keyup #entries-search": "call_search",
      "click #add-admin": "new_admin"
    },

    new_admin: function() {
      document.location.href = document.location.href + '/new';
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
      _.bindAll(this, "render");
      this.collection.bind('reset', this.render);
      this.$search_box = this.$('#entries-search');
      this.setup_search();
      this.search();
    },

    render: function() {
      var view_prototype = this.view_prototype;
      this.$('#entries-list tbody').empty();
      _.each(this.collection.models, function(admin) {
        var view = new view_prototype({model: admin});
        self.$("#entries-list tbody").append(view.render().el);
      });
      this.render_pagination();
    }

  },

  bind_prototypes: function() {
    this.collection_prototype = Backbone.Collection.extend(this.collection_prototype);
    this.view_prototype = Backbone.View.extend(this.view_prototype);
    this.model_prototype = Backbone.Model.extend(this.model_prototype);
    this.app_view_prototype.el = $('#container');
    this.app_view_prototype = Backbone.View.extend(this.app_view_prototype);
  },

  boot: function(page_id) {
    this.bind_prototypes();
    this.collection = new this.collection_prototype(null, {page_id: page_id});
    this.collection.model = this.model_prototype;
    this.app_view = new this.app_view_prototype({collection: this.collection, view_prototype: this.view_prototype});
  }

});
