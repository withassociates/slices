module ControllerHelpers
  def assert_content_type(content_type)
    expect(response.content_type).to eq content_type
  end

  def asset_public_cache_control
    expect(response.headers['Cache-Control']).to eq 'public'
  end

  def asset_expires_header
    expect(response.headers).to include 'Expires'
  end
end

