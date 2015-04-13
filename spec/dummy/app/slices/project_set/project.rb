class Project < Page
  field :client, type: String
  field :description, type: String

  def entry?
    true
  end

  def template
    "project_set/views/show"
  end
end
