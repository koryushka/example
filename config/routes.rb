Rails.application.routes.draw do

  namespace :admin do
    mount_devise_token_auth_for 'Admin', at: 'auth'
    root to: 'home#index'
  end

  namespace :api, defaults: { format: 'json' } do
    namespace :v1 do
      mount_devise_token_auth_for 'User', at: 'auth'
      #resources :users
      get 'users/me' => 'users/me'

      resources :calendars, except: [:edit]
      resources :calendar_items, except: [:edit]
      resources :calendars_groups, except: [:edit]
    end
  end
end
