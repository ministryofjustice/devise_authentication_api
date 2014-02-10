DeviseAuthenticationApi::Application.routes.draw do
  devise_for :users, defaults: {format: :json}, skip: [:sessions, :passwords, :confirmations, :registrations, :unlock]

  # admin view user
  get    'admin/:authentication_token/users' => 'admin/users#show', defaults: {format: :json}

  as :user do
    # registration
    post '/users' => 'registrations#create', as: 'user_registration', defaults: {format: :json}

    # session creation
    post '/sessions' => 'devise/sessions#create', as: 'user_session', defaults: {format: :json}

    # admin registration of user
    post '/admin/:authentication_token/users' => 'admin/registrations#create', defaults: {format: :json}

    # unlock locked account
    post '/users/unlock/:unlock_token' => 'unlocks#create', as: 'user_unlock', defaults: {format: :json}
  end

  # registration confirmation
  post   'users/confirmation/:confirmation_token' => 'confirmations#create', as: 'user_confirmation', defaults: {format: :json}

  # registration activation and password initialization
  post   'users/activation/:confirmation_token' => 'activations#create', defaults: {format: :json}

  # token based authentication
  get    'users/:authentication_token'    => 'tokens#show', defaults: {format: :json}

  # password change
  patch  'users/:authentication_token'    => 'users#update', defaults: {format: :json}

  # session deletion
  delete 'sessions/:authentication_token' => 'sessions#destroy', defaults: {format: :json}


  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
