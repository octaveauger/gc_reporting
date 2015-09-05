Rails.application.routes.draw do
  post 'webhook', to: 'webhook#index'
  
  localized do
    root to: 'home#index'
    get 'reporting', to: 'reporting#index'
    get 'reporting/payments', to: 'reporting#payments'
    get 'reporting/payouts', to: 'reporting#payouts'
    get 'reporting/payout/:payout_gc_id', to: 'reporting#payout', as: 'reporting_payout'
  end

  root to: redirect("/#{I18n.default_locale}", status: 302), as: :redirected_root

  resource :connect, controller: :connect do
    get :authorise, on: :collection
    get :callback, on: :collection
    get :logout, on: :collection
  end
end
