class PageConstraints
  def matches?(request)
    !request.path.start_with?('/admin/auth')
  end
end

class TranslatedPageConstraints
  def matches?(request)
    Slices::Translations.locale_available?(request.params.fetch(:locale, ''))
  end
end

class TranslatedSiteConstraints
  def matches?(request)
    Slices::Translations.available?
  end
end

class UntranslatedSiteConstraints
  def matches?(request)
    ! Slices::Translations.available?
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
    get 'site_maps/update' => 'site_maps#update'
    get 'pages/search' => 'page_search#show'
    resources :pages, :except => [:index, :edit] do
      resources :entries, :only => [:index]
    end
    resources :assets
    resources :snippets
    resources :admins
  end
  get '/admin' => redirect('/admin/site_maps')

  get 'slices/templates(/:slice)/:name.:format' => 'static_assets#templates'
  get ':action/:asset_type(/:folder)/*name.:format' => 'static_assets',
    :constraints => {
    :asset_type => /(stylesheets|javascripts|images)/,
    :action => /(slices|sites)/
  }, :as => :static_assets

  get ':status.html' => 'pages#virtual_error_pages'
  post '*path' => 'pages#create'

  constraints PageConstraints.new do
    constraints TranslatedPageConstraints.new do
      get ':locale/*path' => 'pages#show', as: :page
      get ':locale' => 'pages#show'
    end
    constraints TranslatedSiteConstraints.new do
      get '/', to: redirect("/#{I18n.default_locale}")
    end
    constraints UntranslatedSiteConstraints.new do
      get '*path' => 'pages#show', as: :page
    end
  end

  root to: 'pages#show'
end
