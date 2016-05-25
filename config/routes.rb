Rails.application.routes.draw do
  require 'sidekiq/web'
  mount Sidekiq::Web => '/sidekiq'
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
          registrations: 'devise_overrides/registrations',
          passwords: 'devise_overrides/passwords'
      }
      get 'users/me' => 'users#me'
      #put 'users' => 'users#update'
      get 'google_auth', to: 'google_oauth#auth'
      get 'oauth2callback', to: 'google_oauth#oauth2callback'
      # get 'google_calendars', to: 'google_calendars#index'
      get 'google_calendars/accounts', to: 'google_calendars#accounts'
      put 'google_calendars/accounts/:id/unsync', to: 'google_calendars#unsync_account'
      put 'google_calendars/accounts/:id/sync', to: 'google_calendars#sync_account'
      # get 'google_calendars/sync', to: 'google_calendars#sync'
      put 'google_calendars/calendars/:id/unsync', to: 'google_calendars#unsync_calendar'
      put 'google_calendars/calendars/:id/sync', to: 'google_calendars#sync_calendar'
      post 'google/refresh_token', to: 'google_oauth#refresh_token'
      get 'google/account_info', to: 'google_oauth#get_account_info'
      delete 'google/remove_account', to: 'google_oauth#remove_account'
      # get 'google_calendars/:calendar_id', to: 'google_calendars#show', param: :calendar_id, constraints: { calendar_id: /[^\/]+/ }
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
      post 'events/:id/mute', to: 'events#mute'
      delete 'events/:id/unmute', to: 'events#unmute'

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

      resources :groups, except: [:edit, :new]
      delete 'groups/:id/leave' => 'groups#leave'

      [:lists, :events, :groups].each do |resource|
        resources resource do
          resources :participations, only: [:index, :create, :destroy]
        end
      end
      get 'participations' => 'participations#index_recent'
      post 'participations/:id/accept' => 'participations#accept'
      delete 'participations/:id/decline' => 'participations#decline'

      put 'users/me/profile' => 'profiles#update'
      get 'users/me/profile' => 'profiles#my_profile'
      get 'users/:user_id/profile' => 'profiles#show'

      resources :activities, only: [:index]

      resources :apidocs, only: [:index]

      # devices
      put 'device/:id', to: 'devices#update'
      delete 'device/:id', to: 'devices#destroy'

    end
  end
end
