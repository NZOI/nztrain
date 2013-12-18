NZTrain::Application.routes.draw do
  root :to => "home#home"

  require 'qless/server'
  authenticate :user, ->(current_user) {current_user.is_admin?} do
    get 'qless', :to => 'qless#default', :as => 'qless'
    #constraints ->(request) {request.get?} do
    mount Qless::Server.new($qless) => '/qless/server', :as => 'qless_server' # cannot restrict post requests anymore
    #end
  end

  #resources :ai_contests do
  #  member do
  #    get 'sample'
  #    get 'submit'
  #    post 'submit'
  #    get 'submissions'
  #    get 'scoreboard'
  #    post 'rejudge'
  #    post 'judge'
  #  end
  #end

  #resources :ai_submissions, :only => [:show] do
  #  member do
  #    put 'deactivate'
  #    put 'activate'
  #    post 'rejudge'
  #  end
  #end

  #resources :test_sets
  #resources :test_cases

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

  # resources :contest_relations

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

      get 'export'
      post 'import'
    end
    resources :test_cases, :module => :problems, :only => [:index] do
      patch '', action: :update, on: :collection
    end
    #resources :files, :module => :groups, :except => [:new, :edit]
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

  put 'problem_problem_set/add' => "problem_problem_set#add"
  put 'problem_problem_set/remove' => "problem_problem_set#remove"

  put 'group_problem_set/add' => "group_problem_set#add"

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

end
