Rails.application.routes.draw do

  get 'login' => 'sessions#new', as: 'login'
  post 'login' => 'sessions#create'
  get 'logout' => 'sessions#destroy', as: 'logout'
  get 'register' => 'users#new', as: 'register'

  get 'overview/welcome'
  get 'overview/index'

  resources :users do
    get 'delete_avatar', :action => :delete_avatar
    member do
      put 'like', to: 'users#upvote'
      put 'dislike', to: 'users#downvote'
    end
  end

  resources :locations do
  end

  get '/auth/facebook/callback', to: 'users#link_facebook'
  delete '/auth/facebook', to: 'users#unlink_facebook'
  get '/auth/:provider/callback', to: 'sessions#token'
  get '/auth/failure', to: 'sessions#omniauth_failure'

  get '/partnerships/', to: 'my_partnerships#index' , as: 'partnerships'
  post '/partnerships/:username', to: 'my_partnerships#create', as: 'partnership'
  delete '/partnerships/:username', to: 'my_partnerships#destroy'

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"

  root 'overview#welcome'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  resources :courses do
    collection do
      get 'my_courses_index'
      get 'courses_by_my_coaches_index'
      get 'courses_i_am_subscribed_to_index'
    end
    get 'apply', :action => :apply
    get 'leave', :action => :leave
    get 'export', :action => :export
    resources :training_sessions
  end

  resources :subscriptions do
    collection do
      get 'my_coaches_index'
    end
  end







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
