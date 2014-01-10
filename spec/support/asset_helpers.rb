module AssetHelpers

  def file_fixture name = 'lady bird.jpg'
    File.open file_fixture_path.join name
  end

  def file_fixture_path
    Rails::root.join 'spec', 'fixtures', 'files'
  end

end

