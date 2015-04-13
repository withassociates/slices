class ProjectPresenter < PagePresenter
  include EntryPresenter

  @columns = {
    name: 'Name',
  }
  class << self
    attr_reader :columns
  end

  def main_extra_templates
    ['project_set/project_main', 'project_set/project_more']
  end

  def name
    @source.name.blank? ? "(name isn't set)" : @source.name
  end
end
