Rails.application.routes.draw do
  get "home/index"
  resource :webauthn_session, only: [ :create, :destroy ] do
    post :get_options, on: :collection
  end

  resources :passkeys, only: [ :new, :create, :destroy ] do
    post :create_options, on: :collection
  end

  resources :second_factor_webauthn_credentials, only: [ :new, :create, :destroy ] do
    post :create_options, on: :collection
  end

  resource :second_factor_authentication, only: [ :new, :create ] do
    post :get_options, on: :collection
  end
  resource :session
  resources :passwords, param: :token

  namespace :admin do
    get 'dashboard', to: 'dashboard#index'
    resources :categories
    resources :products
    resources :orders do
      patch :update_status, on: :member
    end
    root to: 'dashboard#index'
  end
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  get "products/:slug", to: "products#show", as: :product_detail

  resource :cart, only: [ :show ]
  resources :cart_items, only: [ :create, :update, :destroy ]
  resources :checkouts, only: [ :new, :create, :show ]

  # Defines the root path route ("/")
  root "home#index"
end
