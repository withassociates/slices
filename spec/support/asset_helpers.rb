module AssetHelpers

  def file_fixture name = 'lady bird.jpg'
    File.open file_fixture_path.join name
  end

  def file_fixture_path
    SLICES_GEM_ROOT.join 'spec', 'fixtures', 'files'
  end

end

