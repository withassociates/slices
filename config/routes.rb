class PageConstraints
  def matches?(request)
    !request.path.start_with?("/admin/auth")
  end
end

Rails.application.routes.draw do

  devise_for :admin, :path => "admin", :controllers => {
    :passwords          => "admin/auth/passwords",
    :sessions           => "admin/auth/sessions",
    :omniauth_callbacks => "admin/auth/omniauth_callbacks",
  }

  namespace :admin do
    match 'site_maps' => 'site_maps#index', :as => :root # Devise redirects here after sign in
    match 'site_maps' => 'site_maps#index'
    match 'site_maps/update' => 'site_maps#update'
    match 'pages/search' => 'page_search#show'
    resources :pages, :except => [:index, :edit] do
      resources :entries, :only => [:index]
    end
    resources :assets
    resources :snippets
    resources :admins
  end
  match '/admin' => redirect('/admin/site_maps')

  match 'slices/templates(/:slice)/:name.:format' => 'static_assets#templates'
  match ':action/:asset_type(/:folder)/*name.:format' => 'static_assets',
    :constraints => {
    :asset_type => /(stylesheets|javascripts|images)/,
    :action => /(slices|sites)/
  }, :as => :static_assets

  match ':status.html' => 'pages#virtual_error_pages'
  match '*path' => 'pages#create', :via => :post
  match '*path' => 'pages#show', :as => :page, :constraints => PageConstraints.new

  root :to => 'pages#show'
end
