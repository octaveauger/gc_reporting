Rails.application.routes.draw do
  post 'webhook', to: 'webhook#index'
  
  localized do
    root to: 'home#index'
    get 'signup', to: 'connect#signup'
    get 'connect/account', to: 'connect#new_account'
    patch 'connect/create', to: 'connect#create_account'
    get 'reporting', to: 'reporting#index'
    get 'reporting/mandates', to: 'reporting#mandates'
    get 'reporting/payments', to: 'reporting#payments'
    get 'reporting/payouts', to: 'reporting#payouts'
    get 'reporting/payout/:payout_gc_id', to: 'reporting#payout', as: 'reporting_payout'

    resources :customers, only: [:show]
    resources :payments, only: [:new, :create]
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
  get "mandates/cancel"
  get "payments/cancel"
  get "payments/retry"
  get "payments/refund"

  resources :mandates, only: [:show]
end
