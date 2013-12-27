module Slices

  # Containers the tree behaviour.
  module Tree
    extend ActiveSupport::Concern

    # @!attribute [rw] path
    # The path for the page, this is a unique identifier and directly maps to
    # the page's url.
    #
    # @return [String]

    # @!attribute [rw] external_url
    # An optional url override for the page, if this is set then this page will
    # link to the url in any navigation block. Usefull when linking to a
    # different website.
    #
    # @return [String]

    # @!attribute [rw] position
    # The page's position amongst it's siblings
    #
    # @return [Integer]

    # @!attribute [rw] show_in_nav
    # If the +page+ should be shown in any navigation block.
    #
    # @return [Boolean]

    # @!method minimal
    # A scope with the minmial attributes needed to render navigaiton
    #
    # @!scope class
    # @return [Mongoid::Criteria]
    #
    included do
      field :path
      field :external_url, type: String, default: ''
      field :position, type: Integer
      field :show_in_nav, type: Boolean, default: false

      scope :minimal, only(%w(page_id path external_url name has_content))
      index({ path: 1 }, { unique: true })

      belongs_to :page

      attr_accessor :parent_id

      before_create :ensure_path_unique
      before_save :ensure_path_unique
    end

    module ClassMethods

      # Get the home page.
      #
      # @return [Page]
      #
      def home
        find_by_path('/')
      end

      # Finds a page by it's path, a {Page::NotFound} is raised if the page
      # can't be found.
      #
      # @return [Page]
      #
      def find_by_path(path)
        first(conditions: { path: path }) || (raise Page::NotFound.new(path))
      end
      alias :f :find_by_path

      # Generate a +path+ from attributes.
      #
      # @param [Hash]   attributes
      # @option attributes [String] :parent_path       Path to parent page
      # @option attributes [Page] :parent              Parent page
      # @option attributes [String] :name              Page name
      # @option attributes [String] :permalink         Permalink
      # @param [Page]  parent
      # @return [String]
      #
      def path_from_attributes(attributes, parent = nil)
        parent_path = if parent
                        parent.path
                      else
                        attributes[:parent_path] || attributes[:parent].try(:path).to_s
                      end
        permalink = attributes.delete(:permalink) || attributes[:name]
        File.join(parent_path, permalink.to_url)
      end
    end

    # Get the parent page.
    #
    # @return [Page]
    def parent
      page
    end

    # Set the parent.
    #
    # @param [Page] page      The new parent
    # @return [Page]
    #
    def parent=(page)
      self.page = page
    end

    # Is this page the home page
    #
    def home?
      path == '/'
    end

    # A list of pages descended from this page ordered by +position+
    #
    # @return [Mongoid::Criteria]
    #
    def children
      Page.where(page_id: self.id).ascending(:position)
    end

    # A list of the page's ancestors
    #
    # @return [Array<Page>]
    #
    def ancestors
      ancestors = []
      parent_page = parent
      while parent_page
        ancestors << parent_page
        parent_page = parent_page.parent
      end
      ancestors
    end

    # Is the current page a descendant of +page+
    #
    # @param [Page] page
    #
    def descended_from?(page)
      ancestors.include?(page)
    end

    # The navigaiton path for a page, the navigation differers from +path+
    # in a few important ways. If #external_url is set then it is returned. If
    # the page has no content and children then the path of it's first child is
    # returned
    #
    # @return [String]
    #
    def navigation_path
      if external_url?
        external_url
      elsif home? || has_content?
        path
      else
        navigable_children.first ? navigable_children.first.path : path
      end
    end

    # A list of child pages which have both +active+ and +show_in_nav+ set to
    # true.  Only the attributes needed to render #navigation are returned,
    # these are: +page_id+, +path+, +external_url+, +name+ and +has_content+.
    #
    # @return [Mongoid::Criteria]
    #
    def navigable_children
      page_children.minimal.where(active: true, show_in_nav: true)
    end

    # The parent pages's navigable children, including this page
    #
    # @return [Mongoid::Criteria]
    #
    def peers
      parent.nil? ? [] : parent.navigable_children
    end

    # An array of the parent page's children excluding this page
    #
    # @return [Mongoid::Criteria]
    #
    def siblings
      parent.nil? ? [] : parent.children.where(:_id.nin => [id])
    end

    # An array of the parent page's children excluding this page, ordered by
    # position
    #
    # @return [Mongoid::Criteria]
    #
    def siblings_by_position
      siblings.ascending(:position)
    end

    # Is this page the first child of its parent
    #
    def first_sibling?
      parent.nil? ? false : peers.first == self
    end

    # Is this page the last child of its parent
    #
    def last_sibling?
      parent.nil? ? false : peers.last == self
    end

    # The previous page(of the parent's active children), or nil
    # if this is the first page.
    #
    # @return [Page]
    #
    def previous_sibling
      index_in_peers < 1 ? nil : peers[index_in_peers - 1]
    end

    # The next page(of the parent's active children), or nil
    # if this is the last page.
    #
    # @return [Page]
    #
    def next_sibling
      peers[index_in_peers + 1]
    end

    # A list of children which are either {Page} or {SetPage}
    #
    # @return [Mongoid::Criteria]
    #
    def page_children
      children.where(:_type.in => [nil, 'Page', 'SetPage'])
    end

    # A list of children which are neither {Page} or {SetPage}
    #
    # @return [Mongoid::Criteria]
    #
    def entry_children
      children.where(:_type.nin => ['Page', 'SetPage'])
    end

    # Recusivly decend from this page and update each descendants path,
    # useful when changing permalinks.
    #
    # @return [Mongoid::Criteria]
    #
    def update_path_for_children
      children.each do |child|
        child.path = child.generate_path
        child.save!
        child.update_path_for_children
      end
    end

    # Generate a new +path+ for the page, using it's parent's path and the
    # permalink.
    #
    # @return [String]
    #
    def generate_path
      unless home?
        File.join(parent.path, permalink)
      else
        '/'
      end
    end

    # The permalink for the page
    #
    # @return [String]
    #
    def permalink
      if path
        File.basename(path)
      else
        name.to_url
      end
    end

    private

    # Make sure that a page's path is unique amoungst it's siblings, if there is
    # a dupliacation then +-1+ is appended
    #
    # @return [void]
    #
    def ensure_path_unique
      if parent.present? && path_changed?
        matching_paths = siblings.where(path: /#{path}(-\d+)?$/)
        if matching_paths.any?
          self.path << "-#{matching_paths.length}"
        end
      end
    end

    # The page's position amoung it's peers
    #
    # @return [Integer]
    #
    def index_in_peers
      parent.nil? ? 0 : peers.only(:id).entries.index(self)
    end
  end
end
