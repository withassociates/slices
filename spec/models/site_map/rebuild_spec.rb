require 'spec_helper'

shared_examples "it has been reparented" do |name, from, to|
  it "be reparented" do
    page = instance_variable_get("@#{name}")
    Page.find_by_path(from).children.include?(page).should be_false
    lambda { Page.find_by_path("#{from}/#{name}") }.should raise_error(Page::NotFound)
    Page.find_by_path("#{to}/#{name}").should be_a Page
  end
end

describe SiteMap do

  def site_map_tree_beneath(page)
    tree = { 'id' => page.id.to_s }
    reloaded_children = Page.find_by_path(page.path).page_children
    if ! reloaded_children.empty?
      tree['children'] = reloaded_children.map { |c| site_map_tree_beneath(c) }
    end
    tree
  end

  def site_map_tree
    [site_map_tree_beneath(@home)]
  end

  def swap_first_children(tree)
    children = tree.first['children']
    children[0], children[1] = children[1], children[0]
    tree
  end

  context "When re-ordering pages" do
    before do
      @home, @parent = StandardTree.build_complex
    end

    it "prevent you from moving the home page" do
      tree = site_map_tree
      tree.first['id'] = 'bad-id-for-home-page'
      lambda { SiteMap.rebuild(tree) }.should raise_error(RuntimeError)
    end

    context "with entries" do
      before do
        @set_page, @articles = StandardTree.add_article_set(@parent)
        @article = @articles.first

        SiteMap.rebuild(site_map_tree)
      end

      it "not include entries in site_map_tree" do
        article_id = @article.id.to_s
        site_map_tree.to_s.index(article_id).should be_false
      end

      it "copy entries" do
        Page.find_by_path(@article.path).should be_a Page
      end

      it "maintain the id of set_page" do
        Page.find_by_path(@set_page.path).id.should eq @set_page.id
      end

      it "maintain the id of entries" do
        Page.find_by_path(@article.path).id.should eq @article.id
      end
    end

    it "swap two siblings" do
      was_first = Page.home.children.first
      was_second = Page.home.children.second
      SiteMap.rebuild(swap_first_children(site_map_tree))
      Page.home.children.second.should eq was_first
      Page.home.children.first.should eq was_second
    end

    def move_child_to_parents_sibling(tree, child_path, new_parent_path)
      child = Page.find_by_path(child_path)
      parent = child.parent
      new_parent = Page.find_by_path(new_parent_path)
      parent_node = tree.first['children'].detect { |node| node['id'] == parent.id.to_s }
      child_node = parent_node['children'].detect { |node| node['id'] == child.id.to_s }
      parent_node['children'].delete(child_node)
      new_parent_node = tree.first['children'].detect { |node| node['id'] == new_parent.id.to_s }
      new_parent_node['children'] ||= []
      new_parent_node['children'] << child_node
      tree
    end

    context "moving a child to a following sibling" do
      before do
        @child = Page.find_by_path('/parent/child')
        @child_id = @child.id
        tree = move_child_to_parents_sibling(site_map_tree, '/parent/child', '/aunt')
        SiteMap.rebuild(tree)
      end

      it_behaves_like "it has been reparented", :child, '/parent', '/aunt'

      it "maintain the id" do
        Page.find_by_path('/aunt/child').id.should eq @child_id
      end
    end

    context "moving a child to a preceding sibling" do
      before do
        StandardTree.add_cousins(Page.find_by_path('/uncle'))
        @cousin = Page.find_by_path('/uncle/cousin')
        @cousin_id = @cousin.id
        tree = move_child_to_parents_sibling(site_map_tree, '/uncle/cousin', '/parent')
        SiteMap.rebuild(tree)
      end

      it_behaves_like "it has been reparented", :cousin, '/uncle', '/parent'

      it "maintain the id" do
        Page.find_by_path('/parent/cousin').id.should eq @cousin_id
      end
    end
  end
end

