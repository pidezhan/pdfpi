Pdfpi::Application.routes.draw do
  get "jobs/index"

  get "jobs/new"

  get "feedback/index", :as => "feedback"
  post "feedback/index"

  # The priority is based upon order of creation:
  # first created -> highest priority.
  resources :jobs do
    member do
      get :download
      get :invalid
      get :expired
      get :p_error
      get :inspect
      post :email
    end
  end
  
  resources :uploads
  get 'home/index'
  get 'home/combine', :as => "combine"
  post 'home/combine'
  get 'home/split', :as => 'split'
  post 'home/split'
  post 'home/sort'
  post 'home/deliver', :as => 'deliver'
  get 'home/deliver_split'
  post 'home/deliver_split', :as => 'deliver_split'
  get 'home/deliver_stamp'
  post 'home/deliver_stamp', :as => 'deliver_stamp'
  get 'home/stamp', :as => "stamp"
  get 'home/test', :as => "test"
  get 'home/why_us', :as => "why_us"
  get 'home/download'
  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
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

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
root :to => 'home#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
