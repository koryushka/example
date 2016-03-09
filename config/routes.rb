Rails.application.routes.draw do

  namespace :admin do
    mount_devise_token_auth_for 'Admin', at: 'auth'
    root to: 'home#index'
  end

  namespace :api, defaults: { format: 'json' } do
    namespace :v1 do
      mount_devise_token_auth_for 'User', at: 'auth'
      get 'users/me' => 'users#me'
      put 'users' => 'users#update'

      resources :calendars, except: [:edit, :new]
      post 'calendars/:id/events/:item_id', to: 'calendars#add_item'
      delete 'calendars/:id/events/:item_id', to: 'calendars#remove_item'
      get 'calendars/:id/events', to: 'calendars#show_items'

      resources :events, except: [:edit, :new] do
        resources :documents, only: [:index, :create]
        resources :notifications_prefs, only: [:index, :create], path: 'notifications'
      end
      post 'events/:id/documents/:document_id', to: 'events#attach_document'
      get 'events/:id/documents', to: 'events#show_documents'
      resources :notifications_prefs, only: [:update, :destroy]

      resources :documents, except: [:new, :edit, :index, :create]
      resources :calendars_groups, except: [:edit, :new]
      resources :lists, except: [:edit, :new] do
        resources :list_items, only: [:index, :create], path: 'items'
      end
      resources :list_items, except: [:new, :edit, :index, :create]
      resources :documents, except: [:edit, :new]
      resources :files, only: [:create]

      resources :sharings, only: [:create, :destroy]
      get 'sharings/resources' => 'sharings#resources'
    end
  end
end
