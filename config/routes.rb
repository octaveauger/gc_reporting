Rails.application.routes.draw do
  post 'webhook', to: 'webhook#index'
  
  localized do
    root to: 'home#index'
    
    get 'signup', to: 'connect#signup'
    get 'connect/account', to: 'connect#new_account'
    patch 'connect/create', to: 'connect#create_account'
    
    resources :account, only: [:index]
    
    resources :clients, only: [:index, :show, :new, :create, :edit, :update] do
      get :mandate_link, on: :collection
      get :new_pending, on: :collection
      post :create_pending, on: :collection
      get :email_mandate
    end

    resources :mandates, only: [:index, :show] do
      get :cancel, on: :collection
    end

    resources :payments, only: [:index, :show, :new, :create] do
      get :cancel, on: :collection
      get :retry, on: :collection
    end
    
    resources :refunds, only: [:new, :create]

    resources :payouts, only: [:index, :show]

    resources :events, only: [] do
      get :payouts, on: :collection
    end
  end

  root to: redirect("/#{I18n.default_locale}", status: 302), as: :redirected_root

  resource :connect, controller: :connect do
    get :authorise, on: :collection
    get :callback, on: :collection
    get :logout, on: :collection
  end

  get "authorisations/new/:flow_id", to: 'authorisations#new', as: 'authorisations_new'
  get "authorisations/confirm/:flow_id", to: 'authorisations#confirm', as: 'authorisations_confirm'
  get "authorisations/error"
  get "authorisations/success"
  get "organisations/sync_status"

  namespace :admin do
    resources :sessions, only: [:new, :create, :destroy]
    get "organisations", to: 'organisations#index'
  end
end
