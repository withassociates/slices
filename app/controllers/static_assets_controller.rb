class StaticAssetsController < SlicesController
  rescue_from ActionController::MissingFile, Errno::ENOENT, with: :render_not_found!

  helper 'pages'

  def templates
    templates_root = params[:slice] ? slice_templates : shared_templates
    path = File.join(templates_root, params[:name])
    path_with_format = [path, params[:format]].join '.'
    send_file_inline path_with_format, content_type: 'text/html; charset=utf-8'
  end

  private

  def mime_type
    if params[:asset_type] == 'images'
      {
        'jpg' => 'image/jpeg',
        'png' => 'image/png',
        'gif' => 'image/gif',
        'svg' => 'image/svg+xml'
      }[params[:format]]
    else
      {
        'stylesheets' => 'text/css',
        'javascripts' => 'application/javascript'
      }[params[:asset_type]]
    end
  end

  def slice_templates
    File.join(Rails.root, 'app', 'slices', params[:slice], 'templates')
  end

  def shared_templates
    File.join(Slices.gem_path, 'public', 'slices', 'templates')
  end

  def send_file_inline(path, options)
    headers['Cache-Control'] = 'public'
    headers['Expires']       = (Time.now + 60 * 60 * 24).utc.httpdate

    options.merge!({
      text: File.open(path).read,
    })
    render options
  end
end

