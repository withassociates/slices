var SnippetsBackbone = $.extend(true, {}, GenericBackbone, {
  collection_prototype: {
    search_url: '/admin/snippets',
    search_data: function() {
      return { search: this.search_term, page: this.page }
    }
  },

  model_prototype: {
    for_template: function() {
      return this.toJSON();
    },

    url: function() {
      return "/admin/snippets/" + this.get('id');
    },
  },

  view_prototype: {
     events: {
      "click a.edit": "edit"
    },

    edit: function(event) {
      event.preventDefault();
      $('#general-modal').jqm({
        ajax: '/admin/snippets/' + this.model.get('id') + '/edit',
        modal: false,
        onHide: function (h) { h.w.fadeOut(100); h.o.fadeOut(100); },
        onShow: function (h) {},
        onLoad: function (h) { h.w.fadeIn(50); h.o.fadeIn(100); },
        overlay: 40
      }).jqmShow();
    },

    tagName: 'tr',
    template: Handlebars.compile(
      "<td>{{key}}</td>" +
      "<td>{{value}}</td>" +
      "<td class='action right'><a href='#' rel='nofollow' id='edit-{{id}}' class='edit button small-button'>Edit</a></td>"
    )

  },

  app_view_prototype: {

    events: {
      "click #add-snippet": "create",
    },

    initialize: function() {
      this.collection = this.options.collection;
      this.view_prototype = this.options.view_prototype;
      _.bindAll(this, "render");
      this.collection.bind('reset', this.render);
      this.bind_create();
      this.search();
    },

    create: function() {
      $('#general-modal').jqm({
        ajax: '/admin/snippets/new',
        modal: false,
        onHide: function (h) { h.w.fadeOut(100); h.o.fadeOut(100); },
        onShow: function (h) {},
        onLoad: function (h) { h.w.fadeIn(50); h.o.fadeIn(100); },
        overlay: 20
      }).jqmShow();
    },

    bind_create: function() {
      var self = this;
      $('#general-modal').bind('ajax:success', function (event, data) {
        if (_.isEmpty(data.errors)) {
          self.search();
          $('#general-modal').jqmHide();
        } else {
          _.each(data.errors, function (error, field) {
            $('#snippet_' + field).parent().addClass('field_with_errors');
            $('#snippet_' + field).parent().append($('<span>' + error + '</span>'));
          });
        }
      })
    },

    render: function() {
      var self = this;
      this.$('#snippets-list tbody').empty();
      _.each(this.collection.models, function(snippet) {
        var view = new self.view_prototype({model: snippet});
        this.$("#snippets-list tbody").append(view.render().el);
      });
      this.render_pagination();
    }

  },

  bind_prototypes: function() {
    this.collection_prototype = Backbone.Collection.extend(this.collection_prototype);
    this.model_prototype = Backbone.Model.extend(this.model_prototype);
    this.app_view_prototype.el = $('#container');
    this.app_view_prototype = Backbone.View.extend(this.app_view_prototype);
    this.view_prototype = Backbone.View.extend(this.view_prototype);
  },

  boot: function() {
    this.bind_prototypes();
    this.collection = new this.collection_prototype
    this.collection.model = this.model_prototype
    this.view = new this.app_view_prototype({collection: this.collection, view_prototype: this.view_prototype})
  }

});
