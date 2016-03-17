Rails.application.routes.draw do

  namespace :admin do
    mount_devise_token_auth_for 'Admin', at: 'auth'
    root to: 'home#index'
  end

  namespace :api, defaults: { format: 'json' } do
    namespace :v1 do
      mount_devise_token_auth_for 'User', at: 'auth', controllers: {
          registrations: 'devise_overrides/registrations'
      }
      get 'users/me' => 'users#me'
      put 'users' => 'users#update'

      resources :calendars, except: [:edit, :new]
      post 'calendars/:id/events/:item_id', to: 'calendars#add_item'
      delete 'calendars/:id/events/:item_id', to: 'calendars#remove_item'
      get 'calendars/:id/events', to: 'calendars#show_items'

      resources :events, except: [:edit, :new] do
        resources :documents, only: [:index]
        resources :notifications_prefs, only: [:index, :create], path: 'notifications'
        resources :event_cancellations, only: [:create], path: 'cancellations'
      end
      post 'events/:id/documents/:document_id', to: 'events#attach_document'
      delete 'events/:id/documents/:document_id', to: 'events#detach_document'

      resources :event_cancellations, only: [:update, :destroy]
      resources :notifications_prefs, only: [:update, :destroy]
      resources :documents, except: [:new, :edit, :index]
      resources :calendars_groups, except: [:edit, :new]
      resources :lists, except: [:edit, :new] do
        resources :list_items, only: [:index, :create], path: 'items'
      end
      resources :list_items, except: [:new, :edit, :index, :create]
      resources :files, only: [:create]

      resources :sharings, only: [:create, :destroy]
      get 'sharings/resources' => 'sharings#resources'
    end
  end
end
