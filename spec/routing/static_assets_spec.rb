require 'spec_helper'

describe "static asset routing", type: :routing do
  it "routes static assets with dots" do
    expect(get('/slices/templates/article_set/article_meta.hbs')).to route_to(
      controller: 'static_assets',
      action:     'templates',
      slice:      'article_set',
      name:       'article_meta',
      format:     'hbs'
    )
  end
end
