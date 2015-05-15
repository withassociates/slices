class PageConstraints
  def matches?(request)
    !request.path.start_with?('/admin/auth')
  end
end

Rails.application.routes.draw do

  devise_for :admin, path: 'admin', controllers: {
    passwords:  'admin/auth/passwords',
    sessions:   'admin/auth/sessions',
  }

  namespace :admin do
    get 'site_maps' => 'site_maps#index', as: :root # Devise redirects here after sign in
    get 'site_maps' => 'site_maps#index'
    put 'site_maps/update' => 'site_maps#update'
    get 'pages/search' => 'page_search#show'
    resources :pages, :except => [:index, :edit] do
      resources :entries, :only => [:index]
    end
    resources :assets
    resources :snippets
    resources :admins
  end
  get '/admin' => redirect('/admin/site_maps')
  get '/admin-new' => 'admin_new#show'

  get 'slices/templates(/:slice)/:name.:format' => 'static_assets#templates'
  get ':action/:asset_type(/:folder)/*name.:format' => 'static_assets',
    :constraints => {
    :asset_type => /(stylesheets|javascripts|images)/,
    :action => /(slices|sites)/
  }, :as => :static_assets

  get ':status.html' => 'pages#virtual_error_pages'
  post '*path' => 'pages#create'
  get '*path' => 'pages#show', as: :page, :constraints => PageConstraints.new

  root to: 'pages#show'
end
