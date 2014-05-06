class Page
  include Mongoid::Document
  include Mongoid::Timestamps
  include MongoSearch::Searchable

  include Slices::Tree
  include Slices::PageAsJSON
  include Slices::HasSlices
  include Slices::HasAttachments::PageInstanceMethods

  DESCRIPTION_DEPRECATION_WARNING = "Page#description is now meta_description. If you are upgrading, run 'rake slices:migrate:meta_description' to update."

  field :name
  field :role  # only relevant for virtual pages
  field :active, type: Boolean, default: false
  field :layout, type: String, default: 'default'
  field :meta_description
  field :title
  field :has_content, type: Boolean, default: false

  belongs_to :author, class_name: 'Admin'

  index :_keywords, background: true

  has_slices :slices
  has_and_belongs_to_many :assets

  text_search_in :introduction, :extended, :name

  scope :entries, all

  def self.available_layouts
    Layout.all.map do |human_name, machine_name|
      { human_name: human_name, machine_name: machine_name }
    end
  end

  scope :virtual, where(:role.ne => nil).asc(:name)
  validates_presence_of :name

  before_save :update_has_content
  before_destroy :destroy_children
  after_save :cache_virtual_page

  class NotFound < RuntimeError; end

  CACHED_VIRTUAL_PAGES = {
    'not_found' => '404',
    'error' => '500'
  }

  def self.role_for_status(status)
    if CACHED_VIRTUAL_PAGES.has_value?(status)
      CACHED_VIRTUAL_PAGES.detect { |k, v| v == status }[0]
    else
      nil
    end
  end

  # Virtual pages don't live in the and are not associated with a
  # specific URL. Instead, they can be rendered at any path, depending
  # on the circumstances (e.g. when a page isn't found, or when an error
  # occurs). Consequently they aren't created with a :parent attribute.
  def self.make(attributes = {})
    attributes = attributes.symbolize_keys
    parent = parent_from_attributes(attributes)
    attributes[:path] ||= path_from_attributes(attributes, parent)

    new(attributes).tap do |page|
      yield(page) if block_given?
      page.parent = parent unless attributes.include?(:role)
      if parent.present?
        page.position = parent.children.count
        page.layout = parent.layout if page.entry?
      end
      page.save
    end
  end

  def self.find_by_id(id)
    find(id)
  rescue BSON::InvalidObjectId, Mongoid::Errors::DocumentNotFound
    nil
  end

  def self.find_by_id!(id)
    find_by_id(id) || (raise NotFound)
  end

  def self.find_virtual(role)
    first(conditions: { role: role })
  end

  def cacheable_virtual_page?
    CACHED_VIRTUAL_PAGES.has_key?(role)
  end

  def cache_virtual_page
    if cacheable_virtual_page? && (! Rails.env.test?)
      fork do
        script = File.join(Slices.gem_path, 'script', 'request-local-page')
        rails = File.join(Rails.root, 'script', 'rails')
        path = "/#{CACHED_VIRTUAL_PAGES[role]}.html"
        FileUtils.rm_f(File.join(Rails.root, 'public', path))
        exec(rails, 'runner', '-e', Rails.env, script, path)
      end
    end
  end

  def virtual?
    role.present?
  end

  def entry?
    false
  end

  def set_page?
    kind_of?(SetPage)
  end

  def sets
    slices.select { |slice| slice.kind_of?(SetSlice) }
  end

  def set_slice(kind)
    slice_class = Object.const_get("#{kind.to_s}SetSlice".camelize)
    slices.detect { |slice| slice.kind_of?(slice_class) }
  end

  def template
    "pages/show"
  end

  def update_attributes(attributes)
    attributes = attributes.symbolize_keys

    unless home?
      if attributes.has_key?(:name) || attributes.has_key?(:permalink)
        new_path = self.class.path_from_attributes(attributes, parent)
        attributes[:path] = new_path if new_path != path
      end
      if attributes.has_key?(:path) && attributes[:path].blank?
        attributes.delete(:path)
      end
    end

    super
    if valid?
      update_path_for_children if attributes.has_key?(:path)
    end
  end


  # Added in merge or page & content
  def set_keywords
    super
    slices.each do |slice|
      self._keywords += MongoSearch::KeywordsExtractor.extract(slice.search_text)
    end
    self._keywords.uniq!
  end

  def available_layouts
    self.class.available_layouts
  end

  # End of added

  def description
    ActiveSupport::Deprecation::warn DESCRIPTION_DEPRECATION_WARNING
    meta_description
  end

  def description=(value)
    ActiveSupport::Deprecation::warn DESCRIPTION_DEPRECATION_WARNING
    self.meta_description = value
  end

  private
    def self.parent_from_attributes(attributes)
      if attributes.has_key?(:parent_path)
        Page.find_by_path(attributes.delete(:parent_path))
      elsif attributes.has_key?(:parent_id)
        Page.find_by_id(attributes.delete(:parent_id))
      else
        attributes.delete(:parent)
      end
    end

    def self.page_exists?(path)
      Page.find_by_path(path)
    rescue NotFound
      false
    end

    def update_has_content
      self.has_content = slices.any?
      true # must be true otherwise save will fail
    end

    def destroy_children
      children.each { |child| child.destroy }
    end

end
