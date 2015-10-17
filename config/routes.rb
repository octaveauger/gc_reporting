Rails.application.routes.draw do
  post 'webhook', to: 'webhook#index'
  
  localized do
    root to: 'home#index'
    get 'reporting', to: 'reporting#index'
    get 'reporting/mandates', to: 'reporting#mandates'
    get 'reporting/payments', to: 'reporting#payments'
    get 'reporting/payouts', to: 'reporting#payouts'
    get 'reporting/payout/:payout_gc_id', to: 'reporting#payout', as: 'reporting_payout'

    resources :customers, only: [:show]
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
end
