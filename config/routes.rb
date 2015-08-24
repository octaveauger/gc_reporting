Rails.application.routes.draw do
  root to: 'home#index'
  get "gocardless/sync"
  get "gocardless", to: 'gocardless#index'
  get "reporting", to: 'reporting#index'
  get "reporting/payments", to: 'reporting#payments'

  resource :connect, controller: :connect do
    get :authorise, on: :collection
    get :callback, on: :collection
    get :logout, on: :collection
  end
end
