Rails.application.routes.draw do
  root to: 'home#index'
  get "export-customers", to: 'reporting#export_customers', as: 'export_customers'

  resource :connect, controller: :connect do
    get :authorise, on: :collection
    get :callback, on: :collection
    get :logout, on: :collection
  end
end
