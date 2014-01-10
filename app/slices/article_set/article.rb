class Article < Page
  include Slices::HasAttachments

  class FeaturedImage < Attachment
    field :caption
  end

  has_attachments :images, class_name: "Article::FeaturedImage"

  field :author, type: String
  field :categories, type: Array
  field :published_at, type: Time

  index [
    [:published_at, Mongo::DESCENDING],
    [:active, Mongo::ASCENDING]
  ]
  index :categories

  scope :published, -> {
    where(:published_at.lte => Time.now, active: true).
    descending(:published_at)
  }

  def self.categories
    all.distinct :categories
  end

  def entry?
    true
  end

  def template
    "article_set/views/show"
  end

  def available_categories
    self.class.categories
  end

  def available_authors
    %w[Will Alex Jez]
  end

  def as_json options = {}
    super(options).merge(
      available_authors: available_authors,
      available_categories: available_categories,
      images: images
    )
  end

end

