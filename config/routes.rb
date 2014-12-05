Rocky::Application.routes.draw do
  
  root :to => "registrants#landing"
  match "/registrants/timeout", :to => "timeouts#index", :as=>'registrants_timeout'
  resources "registrants", :only => [:new, :create, :show, :update] do
    resource "step_1", :controller => "step1", :only => [:show, :update]
    resource "step_2", :controller => "step2", :only => [:show, :update]
    resource "step_3", :controller => "step3", :only => [:show, :update]
    resource "step_4", :controller => "step4", :only => [:show, :update]
    resource "step_5", :controller => "step5", :only => [:show, :update]
    resource "download", :only => :show
    resource "finish", :only => :show
    resource "ineligible", :only => [:show, :update]
    resources "tell_friends", :only => :create
    resource "state_online_registration", :only=>:show
    member do 
      get "stop_reminders", :to=>'reminders#stop', :as=>'stop_reminders'
    end
  end

  resource  "partner_session"
  match  "login",  :to => "partner_sessions#new", :as=>'login'
  match "logout", :to => "partner_sessions#destroy", :as=>'logout'
  
  resource "partner", :path_names => {:new => "register", :edit => "profile"} do
    member do
      get "statistics"
      get "registrations"
      get "download_csv"
      get "embed_codes"
    end
    resource "questions",     :only => [:edit, :update]
    resource "widget_image",  :only => [:show, :update]
    resource "logo",          :only => [:show, :update, :destroy]
  end
  
  match "/widget_loader.js", :format => "js", :to => "registrants#widget_loader", :as=>'widget_loader'
  
  resources "password_resets", :only => [:new, :create, :edit, :update]

  resources "state_configurations", :only=>[:index, :show] do
    collection do
      post :submit
    end
  end
  
  resources "translations", :only=>[:index, :show] do
    collection do
      get :all_languages
    end
    member do
      post :submit
      get :preview_pdf
    end
  end

  namespace :api do
    namespace :v1 do
      resources :registrations, :only=>[:index, :create], :format=>'json'
      resource :state_requirements, :only=>:show, :format=>'json'
    end
    namespace :v2 do
      resources :registrations, :only=>[:index, :create], :format=>'json'
      resource :state_requirements, :only=>:show, :format=>'json'

      resources :partners, :only=>[:create], :format=>'json' do
        collection do
          get "partner", :action=>"show"
        end
      end
      
      resources :registration_states, :as=>:gregistrationstates, :format=>'json', :only=>'index'      
      
      resources :partners, :path=>'partnerpublicprofiles', :only=>[], :format=>'json' do
        collection do
          get "partner", :action=>"show_public"
        end
      end
      match 'gregistrations',      :format => 'json', :controller => 'registrations', :action => 'index_gpartner', :via => :get
      match 'gregistrations',      :format => 'json', :controller => 'registrations', :action => 'create_finish_with_state', :via => :post
    end
    namespace :v3 do
      resources :registrations, :only=>[:index, :create], :format=>'json' do
        collection do
          get "pdf_ready", :action=>"pdf_ready"
          post "stop_reminders", :action=>"stop_reminders"
          post "bulk", :action=>"bulk"
        end
      end
      resource :state_requirements, :only=>:show, :format=>'json'

      resources :partners, :only=>[:show, :create], :format=>'json'
      
      resources :registration_states, :as=>:gregistrationstates, :format=>'json', :only=>'index'      
      
      resources :partners, :path=>'partnerpublicprofiles', :only=>[], :format=>'json' do
        collection do
          get "partner", :action=>"show_public"
        end
      end
      match 'gregistrations',      :format => 'json', :controller => 'registrations', :action => 'index_gpartner', :via => :get
      match 'gregistrations',      :format => 'json', :controller => 'registrations', :action => 'create_finish_with_state', :via => :post
    end
  end

  namespace :admin do
    root :controller => 'partners', :action => 'index'
    resources :partners do
      member do
        get :regen_api_key
      end
      resources :assets, :only => [ :index, :create, :destroy ]
    end
    resources :government_partners
    resource :partner_zips, :only=>[:create]
  end
    
  # The priority is based upon order of creation:
  # first created -> highest priority.

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
  # root :to => 'welcome#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
