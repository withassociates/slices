class SiteMap
  def self.rebuild(tree)
    set_children_for(tree.first['id'], tree.first['children'])
  end

  def permalink
    '{root}'
  end

  def self.set_children_for(parent_id, data)
    parent = Page.find(parent_id)
    data.each_with_index do |child_data, i|
      child = Page.find(child_data['id'])
      child.position = i
      child.parent = parent
      child.path = child.generate_path
      child.save!
      set_children_for(child_data['id'], child_data['children']) if child_data['children']
    end
  end
  private_class_method :set_children_for
end
