class Layout
  def self.all
    files.map do |layout|
      layout = layout.split('/').last.gsub(file_extension, '')
      [layout.titleize, layout]
    end
  end

  def self.files
    files = []
    SlicesController.view_paths.each do |resolver|
      query = File.join(resolver, 'layouts', "*#{file_extension}")
      files.concat(Dir.glob(query))
    end
    files.reject do |file|
      file.include?('admin.html.erb')
    end.uniq.sort
  end

  def self.file_extension
    '.html.erb'
  end

  def initialize(name)
    @name = name
  end

  def path
    self.class.files.select do |path|
      path.split('/').last == @name + self.class.file_extension
    end.first
  end

  def containers
    parser = Slices::ContainerParser.new(path)
    parser.parse
  end
end
