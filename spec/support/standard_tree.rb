class StandardTree
  def self.build_virtual
    not_found = Page.make(
      role:    'not_found',
      name:    'Page not found',
      active:  true
    )
    error = Page.make(
      role:    'error',
      name:    'Something went wrong',
      active:  true
    )
    [not_found, error]
  end

  def self.build_home
    Page.make(
      name:        'Home',
      permalink:   '',
      active:      true,
      show_in_nav: true
    )
  end

  def self.build_minimal
    home = build_home
    parent = Page.make(
      parent:      home,
      name:        'Parent',
      permalink:   'parent',
      active:      true,
      show_in_nav: true
    )
    [home, parent]
  end

  def self.build_minimal_with_slices
    home, parent = build_minimal

    parent.slices.build({
      title:     'Title',
      container: 'container_one',
      position:  0
    }, TitleSlice)
    parent.slices.build({
      textile:   'h2. Textile',
      container: 'container_two',
      position:  0
    }, TextileSlice)

    parent.save!

    [home, parent]
  end

  def self.add_complex(home, parent)
    child = Page.make(
      parent:      parent,
      name:        'Child',
      permalink:   'child',
      active:      true,
      show_in_nav: true
    )
    grand_child = Page.make(
      parent:      child,
      name:        'Grand child',
      permalink:   'grand-child',
      active:      true,
      show_in_nav: true
    )
    Page.make(
      parent:      parent,
      name:        'Sibling',
      permalink:   'sibling',
      active:      true,
      show_in_nav: true
    )
    Page.make(
      parent:      parent,
      name:        'Youngest',
      permalink:   'youngest',
      active:      true,
      show_in_nav: true
    )
    Page.make(
      parent:      home,
      name:        'Aunt',
      permalink:   'aunt',
      active:      true,
      show_in_nav: true
    )
    Page.make(
      parent:      home,
      name:        'Uncle',
      permalink:   'uncle',
      active:      true,
      show_in_nav: true
    )
    [child, grand_child]
  end

  def self.build_complex
    home, parent = build_minimal
    add_complex(home, parent)
    [home, parent]
  end

  def self.add_cousins(uncle)
    cousin = Page.make(
      parent:      uncle,
      name:        'Cousin',
      permalink:   'cousin',
      active:      true,
      show_in_nav: true
    )
    Page.make(
      parent:      cousin,
      name:        'Once Removed',
      permalink:   'once-removed',
      active:      true,
      show_in_nav: true
    )
  end

  def self.add_slices_beneath(page, container = nil)
    page.slices << TitleSlice.new(title: page.name, container: container)
    page.save!
    page.children.each { |child| add_slices_beneath(child, container) }
  end

  def self.add_admin(attrs = {})
    Admin.create!({
      name:                  'Admin',
      email:                 'hello@withassociates.com',
      password:              '123456',
      password_confirmation: '123456',
    }.merge(attrs))
  end

  # /
  # /parent
  # /parent/articles
  # /parent/articles/article-1
  # /parent/articles/article-2
  def self.add_article_set(parent, options={})
    set_page = SetPage.make({
      parent:      parent,
      name:        'Articles',
      permalink:   'articles',
      active:      true,
      show_in_nav: true
    }.merge(options))

    set_page.slices << ArticleSetSlice.new(
      container: 'container_one'
    )
    set_page.set_slices << TextileSlice.new(
      textile:   'I appear above every article.',
      container: 'container_one'
    )
    set_page.set_slices << PlaceholderSlice.new(
      container: 'container_one'
    )
    set_page.set_slices << TextileSlice.new(
      textile:   'I appear below every article.',
      container: 'container_one'
    )

    set_page.save!

    articles = (1..2).collect { self.add_article(set_page) }
    [set_page, articles]
  end

  def self.add_article(set_page)
    i = Article.count + 1
    Article.make(
      parent:     set_page,
      name:       "Article #{i}",
      permalink:  "article-#{i}",
      published_at: i.weeks.ago,
      active:     true
    ).tap do |page|
      page.slices << TitleSlice.new(
        title:     "Article #{i}",
        container: 'container_one'
      )
      page.save!
    end
  end
end
