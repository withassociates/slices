module ControllerHelpers
  def assert_content_type(content_type)
    response.content_type.should eq content_type
  end

  def asset_public_cache_control
    response.headers['Cache-Control'].should eq 'public'
  end

  def asset_expires_header
    response.headers.should include 'Expires'
  end
end

