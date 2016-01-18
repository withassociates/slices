# This module provices helpers for rendering common navigation from page structure
#
#   primary_navigation
#   # =>  <ul id="primary_navigation">
#   # =>    <li class="first active nav-home"><a href="/">Home page</a></li>
#   # =>    <li class="nav-about"><a href="/about">About us</a></li>
#   # =>    <li class="last nav-blog"><a href="/blog">Blog</a></li>
#   # =>  </ul>
#
module NavigationHelper

  #   primary_navigation
  #   # =>  <ul id="primary_navigation">
  #   # =>    <li class="first active nav-home"><a href="/">Home page</a></li>
  #   # =>    <li class="nav-about"><a href="/about">About us</a></li>
  #   # =>    <li class="nav-parent"><a href="/parent">Parent</a></li>
  #   # =>    <li class="nav-aunt"><a href="/aunt">Aunt</a></li>
  #   # =>    <li class="nav-uncle"><a href="/uncle">Uncle</a></li>
  #   # =>    <li class="last nav-blog"><a href="/blog">Blog</a></li>
  #   # =>  </ul>
  #
  # @param [String]       id        Dom id of the surronding ul element
  # @return [String]
  #
  def primary_navigation(id = 'primary_navigation')
    cache cache_key_for_navigation(id) do
      benchmark 'Rendered primary_navigation' do
        nav = navigation(page: Page.home, depth: 1, id: id)
        safe_concat nav
        ''
      end
    end
  end

  # Render the secondary navigation if the current page isn't already rendered
  # in the primary navigation.
  #
  #   secondary_navigaiton :depth => 10
  #   # =>  <ul id="secondary_navigation">
  #   # =>    <li class="first nav-parent-child"><a href="/parent/child">Child</a>
  #   # =>      <ul>
  #   # =>        <li class="first last nav-parent-child-grand-child"><a href="/parent/child/grand-child">Grand child</a></li>
  #   # =>      </ul>
  #   # =>    </li>
  #   # =>    <li class="nav-parent-sibling"><a href="/parent/sibling">Sibling</a></li>
  #   # =>    <li class="last nav-parent-youngest"><a href="/parent/youngest">Youngest</a></li>
  #   # =>  </ul>
  #
  # @param  [Hash]       options
  # @option options [Integer] :depth (1)                    Number of levels to render
  # @option options [String] :id ('secondary_navigation')  Id of surrounding UL
  # @return [String]
  #
  def secondary_navigation(options = {})
    name = options.fetch('id') { 'secondary_navigation' }
    cache cache_key_for_navigation(name) do
      benchmark 'Rendered secondary_navigation' do
        secondary_ancestors = (@page.ancestors[-2] || @page).navigable_children
        nav = if secondary_ancestors.empty? || @page.home?
                ''
              else
                page = secondary_ancestors.first
                navigation(options.reverse_merge(page: page, id: 'secondary_navigation'))
              end
        safe_concat nav
        ''
      end
    end
  end

  # Use the page structure to render nested navigation, each visible page is
  # rendered in a +li+ element with child pages in a nested +ul+
  #
  # The first +li+ in a +ul+ has the class +first+, the last +li+ in a +ul+ has
  # the class +last+ and the current page has the class +active+.
  #
  # Each +li+ has a class identifier generated from it's path and prefixed with
  # +nav+, for example a page with path +/parent/child+ would have the class
  # +nav-parent-child+. This identifier is a class is to avoid duplicate +ids+
  # if multiple navigation elements are used on a page.
  #
  # The home page is assumed to be at the same level as it's children.
  #
  #   navigation depth: 4, page: Page.home, id: 'navigation'
  #   # =>  <ul id="navigation">
  #   # =>    <li class="first nav-home"><a href="/">Home page</a></li>
  #   # =>    <li class="nav-about"><a href="/about">About us</a></li>
  #   # =>    <li class="active nav-parent">
  #   # =>      <a href="/parent">Parent</a>
  #   # =>      <ul>
  #   # =>        <li class="first nav-parent-child">
  #   # =>          <a href="/parent/child">Child</a>
  #   # =>          <ul>
  #   # =>            <li class="first last nav-parent-child-grand-child"><a href="/parent/child/grand-child">Grand child</a></li>
  #   # =>          </ul>
  #   # =>        </li>
  #   # =>        <li class="nav-parent-sibling"><a href="/parent/sibling">Sibling</a></li>
  #   # =>        <li class="last nav-parent-youngest"><a href="/parent/youngest">Youngest</a></li>
  #   # =>      </ul>
  #   # =>    </li>
  #   # =>    <li class="nav-aunt"><a href="/aunt">Aunt</a></li>
  #   # =>    <li class="nav-uncle"><a href="/uncle">Uncle</a></li>
  #   # =>    <li class="last nav-blog"><a href="/blog">Blog</a></li>
  #   # =>  </ul>
  #
  #   navigation depth: 1, page: Page.home
  #   # =>  <ul>
  #   # =>    <li class="first nav-home"><a href="/">Home page</a></li>
  #   # =>    <li class="nav-about"><a href="/about">About us</a></li>
  #   # =>    <li class="active nav-parent"><a href="/parent">Parent</a></li>
  #   # =>    <li class="nav-aunt"><a href="/aunt">Aunt</a></li>
  #   # =>    <li class="nav-uncle"><a href="/uncle">Uncle</a></li>
  #   # =>    <li class="last nav-blog"><a href="/blog">Blog</a></li>
  #   # =>  </ul>
  #
  # @param  [Hash]       options
  # @option options [Integer] :depth (1)              Number of levels to render
  # @option options [Integer] :page  (current_page)   Page to start rendering
  # @option options [Integer] :id                     Id of surrounding UL
  # @option options [Integer] :class                  Class of surrounding UL
  # @return [String]
  #
  def navigation(options = {})
    options.reverse_merge!(page: @page, depth: 1)
    page = options[:page]
    children = page.home? ? page.navigable_children : page.parent.navigable_children
    html = (is_home_and_shown_in_nav?(page) ? nav_link(Page.home) : '').html_safe
    html << list_items(children, options[:depth])
    content_tag(:ul, html, options.slice(:id, :class))
  end

  # Link to a +page+, using the page name as the link name.
  #
  #   link_to Page.find_by_path('/parent')
  #   # => <a href="/parent">Parent</a>
  #
  # @param  [Page]       page                         Page to link to
  # @return [String]
  #
  def link_to_page(page)
    link_to(page.name, page.navigation_path)
  end

  private

  def list_items(pages, depth)
    depth -= 1
    pages.inject(''.html_safe) do |html, page|
      html << nav_link(page, depth)
    end
  end

  def nav_link(page, depth = 0)
    content_tag(:li, class: nav_list_item_class(page)) do
      html = link_to_page(page)
      if (depth > 0) && page.navigable_children.any?
        html << content_tag(:ul, list_items(page.navigable_children, depth))
      end
      html
    end + "\n"
  end

  def is_home_and_shown_in_nav?(page)
    page.home? && page.show_in_nav?
  end

  def is_first_sibling?(page)
    if page.home? || is_home_and_shown_in_nav?(page.parent)
      page.home?
    else
      page.first_sibling?
    end
  end

  def is_active_sibling?(page)
    if page.home?
      page == @page
    else
      (page == @page) || @page.descended_from?(page)
    end
  end

  def nav_list_item_class(page)
    classes = []
    classes << 'first' if is_first_sibling?(page)
    classes << 'active' if is_active_sibling?(page)
    classes << 'last' if page.last_sibling?
    classes << nav_list_identifier(page)
    classes.empty? ? nil : classes.join(' ')
  end

  def nav_list_identifier(page)
    page.home? ? 'nav-home' : ('nav' + page.path.gsub('/', '-'))
  end

  def cache_key_for_navigation(name)
    ['pages', @page.id, name, Page.last_changed_at]
  end
end

