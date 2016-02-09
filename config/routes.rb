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

      resources :calendars, except: [:edit, :new]
      resources :calendar_items, except: [:edit, :new] do
        resources :documents, only: [:index, :create]

      end
      post 'calendar_items/:id/documents/:document_id', to: 'calendar_items#attach_document'
      get 'calendar_items/:id/documents', to: 'calendar_items#show_documents'

      resources :documents, except: [:new, :edit, :index, :create]
      resources :calendars_groups, except: [:edit, :new]
      resources :lists, except: [:edit, :new] do
        resources :list_items, only: [:index, :create], path: 'items'
      end
      resources :list_items, except: [:new, :edit, :index, :create]
      resources :documents, except: [:edit, :new]
      resources :files, only: [:create]
    end
  end
end
