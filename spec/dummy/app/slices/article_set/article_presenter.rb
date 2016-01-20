class ArticlePresenter < PagePresenter
  include EntryPresenter

  @columns = {
    name: 'Name',
    content: 'Content',
    published_at: 'Date Published'
  }
  class << self
    attr_reader :columns
  end

  def main_extra_template
    'article_set/article_main'
  end

  def meta_extra_template
    'article_set/article_meta'
  end

  def name
    @source.name.blank? ? '(no name)' : @source.name
  end

  def content
    slice = @source.slices.detect { |s| s.kind_of?(TextileSlice) }
    text = slice.try(:textile)
    text.blank? ? '(no content)' : truncate(text, length: 63)
  end

  def published_at
    @source.published_at || '-'
  end
end
