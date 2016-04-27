Rails.application.routes.draw do
  namespace :admin do
    #mount_devise_token_auth_for 'Admin', at: 'auth'
    root to: 'home#index'
  end

  namespace :api, defaults: { format: 'json' } do
    namespace :v1 do
      use_doorkeeper do
        controllers tokens: 'tokens'
        skip_controllers :authorizations, :applications, :authorized_applications
      end
      mount_devise_token_auth_for 'User', at: 'users', controllers: {
          registrations: 'devise_overrides/registrations'
      }
      get 'users/me' => 'users#me'
      #put 'users' => 'users#update'

      resources :calendars, except: [:edit, :new] do
        post 'events/:id', to: 'events#add_to_calendar'
        delete 'events/:id', to: 'events#remove_from_calendar'
        get 'events', to: 'events#index_of_calendar'
      end

      resources :events, except: [:edit, :new] do
        resources :notifications_prefs, only: [:index, :create], path: 'notifications'
        resources :event_cancellations, only: [:create], path: 'cancellations'
      end
      post 'events/:id/lists/:list_id', to: 'events#add_list'
      delete 'events/:id/lists/:list_id', to: 'events#remove_list'

      resources :event_cancellations, only: [:update, :destroy]
      resources :notifications_prefs, only: [:update, :destroy]
      resources :calendars_groups, except: [:edit, :new]
      resources :files, only: [:show, :create, :destroy]

      resources :lists, except: [:edit, :new] do
        resources :list_items, except: [:new, :edit], path: 'items'
      end
      get 'lists/:list_id/events', to: 'events#index_of_list'

      resources :sharings, only: [:create, :destroy]
      get 'sharings/resources' => 'sharings#resources'

      resources :groups, except: [:edit, :new] do
        get 'users' => 'users#group_index'
        post 'users/:id' => 'users#add_to_group'
        delete 'users/:id' => 'users#remove_from_group'
      end

      put 'users/me/profile' => 'profiles#update'
      get 'users/me/profile' => 'profiles#my_profile'
      get 'users/:user_id/profile' => 'profiles#show'
    end
  end
end
