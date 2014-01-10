var GenericBackbone = {
  collection_prototype: {
    page: 1,
    total_pages: 1,
    search_term: '',
    search: function() {
      var self = this;
      $.get(self.search_url, this.search_data(), function(results) {
        self.page = results.current_page;
        self.total_pages = results.total_pages;
        self.reset(results.items);
      }, 'json');
    }

  },

  model_prototype: {
    idAttribute: '_id',

    clear: function() {
      this.view.remove();
      this.destroy();
    }
  },

  view_prototype: {
    initialize: function() {
      this.model.view = this;
    },

    remove: function() {
      $(this.el).remove();
    },

    clear: function() {
      this.model.clear();
      return false;
    },

    render: function() {
      $(this.el).html(this.template(this.model.for_template()));
      return this;
    },
  },

  app_view_prototype: {
    render_pagination: function() {
      $pagination = this.$('#pagination');
      if (this.collection.total_pages === 1) {
        $pagination.empty();
        return
      }
      var self = this;
      var pages = [];
      for (var page = 1; page <= self.collection.total_pages; page++) {
        if (page === this.collection.page) {
          pages.push({num: page, klass:  'active'});
        } else if ((page === this.collection.page + 1) || (page === this.collection.page -1)) {
          pages.push({num: page, klass:  ''})
        } else if ((page <= 2) || (page > (this.collection.total_pages - 2))) {
          pages.push({num: page, klass:  ''})
        }
      }
      $pagination.empty();
      _.each(pages, function(page, index) {
        $pagination.append($("<a />", {text: page.num, className: page.klass, href: '#'}));
        if ((pages[index+1]) && (pages[index+1].num != page.num+1)) {
          $pagination.append($('<span>...</span>').wrap('<li />'));
        }
      });
      $pagination.find("a, span").wrap(document.createElement('li'));
    },

    paginate: function(e) {
      var page_num = $(e.target).text();
      this.collection.page = page_num;
      this.search();
    },

    setup_search: function() {
      var self = this;
      setInterval(function() {
        if ( self.search_now ) {
          self.search_now = false;
          self.collection.page = 1;
          self.search();
        }
      }, 250);
    },

    call_search: function() {
      this.search_now = true;
    },

    search: function() {
      this.collection.search_term = this.$('#entries-search').val();
      this.collection.search();
    }

  }
}
