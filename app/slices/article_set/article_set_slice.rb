class ArticleSetSlice < SetSlice

  def entries
    Article.published
  end

  def page_entries params = {}
    entries.paginate paginate_options params
  end

end
