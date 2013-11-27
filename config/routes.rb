NZTrain::Application.routes.draw do
  root :to => "home#home"

  require 'sidekiq/web'
  authenticate :user, ->(current_user) {current_user.is_admin?} do
    get 'sidekiq', :to => 'sidekiq#default', :as => 'sidekiq'
    constraints ->(request) {request.get?} do
      mount Sidekiq::Web => '/sidekiq/web', :as => 'sidekiq_web'
    end
  end
  authenticate :user, ->(current_user){current_user.has_role?(:superadmin)} do
    mount Sidekiq::Web => '/sidekiq/web', :as => 'sidekiq_web'
  end

  resources :ai_contests do
    member do
      get 'sample'
      get 'submit'
      post 'submit'
      get 'submissions'
      get 'scoreboard'
      post 'rejudge'
      post 'judge'
    end
  end

  resources :ai_submissions, :only => [:show] do
    member do
      put 'deactivate'
      put 'activate'
      post 'rejudge'
    end
  end

  resources :test_sets

  resources :evaluators

  resources :settings

  resources :roles

  resources :contests do
    collection do
      get 'my', :to => 'contests#index', :defaults => { :filter => 'my' }
      get 'active', :to => 'contests#browse', :defaults => { :filter => 'active' }
      get 'current', :to => 'contests#browse', :defaults => { :filter => 'current' }
      get 'upcoming', :to => 'contests#browse', :defaults => { :filter => 'upcoming' }
      get 'past', :to => 'contests#browse', :defaults => { :filter => 'past' }
    end
    member do
      get 'info'
      get 'scoreboard'

      put 'start'
      put 'finalize'
      put 'unfinalize'
    end
  end

  resources :contest_relations

  resources :submissions, :except => [:new,:create] do
    collection do
      get '(by_user/:by_user)(/by_problem/:by_problem)', :action => :index, :constraints => {:by_user => /[\d,]+/, :by_problem => /[\d,]+/}
      get 'my', :to => 'submissions#index', :defaults => { :filter => 'my' }
    end
    member do
      post 'rejudge'
    end
  end

  resources :problems do
    collection do
      get 'my', :to => 'problems#index', :defaults => { :filter => 'my' }
    end
    member do
      post 'submit'
      get 'submit'
      get 'submissions'
    end
  end

  resources :problem_sets do
    collection do
      get 'my', :to => 'problem_sets#index', :defaults => { :filter => 'my' }
    end
    member do
      put 'add_problem'
      put 'remove_problem'
    end
  end

  resources :test_cases

  resources :users, :only => :index do
    collection do
      post 'suexit'

      get 'online'
      get 'newest'
    end
  end

  resources :user, :only => [:index, :show, :edit, :update, :destroy] do
    member do
      put 'add_role'
      put 'remove_role'
      post 'su'
      get 'su'
      get 'admin_email'
      post 'admin_email', :action => :send_admin_email
      post 'add_brownie'
    end
  end

  devise_for :users, :path => "accounts", :controllers => { :registrations => "accounts/registrations", :settings => "accounts/settings", :confirmations => "accounts/confirmations", :passwords => "accounts/passwords" }

  devise_scope :user do
    namespace :accounts do
      get 'edit/:type', :to => 'registrations#edit'
      put 'update/:type', :to => 'registrations#update'
      get 'settings/edit', :to => 'settings#edit'
      put 'settings/update', :to => 'settings#update'

      get 'requests', :to => 'requests#index'
    end
  end

  match 'problem_problem_set/:action(:format)' => "problem_problem_set"

  match 'group_problem_set/:action(:format)' => "group_problem_set"

  resources :groups do
    collection do
      get 'my', :to => 'groups#index', :defaults => { :filter => 'my' }
      get 'browse'

      put 'add_problem_set'
      put 'add_contest'
    end
    member do
      get 'contests'
      get 'info'

      scope path: :members, module: :groups, controller: :members do
        put 'join'
        put 'leave'
        put 'apply'

        scope as: :members do
          get '', action: :index, as: ''

          get 'invites'
          post 'invites'
          get 'join_requests'

          put 'accept/:request_id', action: :accept, as: :accept
          put 'reject/:request_id', action: :reject, as: :reject
          put 'cancel/:request_id', action: :cancel, as: :cancel
        end
      end

      put 'remove_problem_set'
      put 'remove_contest'
    end
    resources :files, :module => :groups, :except => [:new, :edit]
  end

  resources :file_attachments do
    collection do
      get 'my', :to => 'file_attachments#index', :defaults => { :filter => 'my' }
    end
    member do
      get 'download'
    end
  end

  resources :zipped_test_cases do
    member do
      post 'upload'
      get 'download'
    end
  end

  #match 'groups/:id/add_user(:format)' => 'groups#add_user'
  #match 'groups/:id/remove_user(:format)' => 'groups#remove_user'

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
  # root :to => "welcome#index"

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'
  #
end
