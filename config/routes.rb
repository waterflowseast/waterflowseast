Waterflowseast::Application.routes.draw do
  root to: 'posts#index'

  resources :posts, except: [:show, :edit, :update] do
    memember do
      get :show_direct_comments
      get :show_total_comments
      get :show_collectors
      get :show_voting_ups
      get :show_voting_downs

      get :change_node
      get :change_title
      get :change_content
      get :change_extra_info

      put :update_node
      put :update_title
      put :update_content
      put :update_extra_info
    end
  end

  resources :users, except: [:show, :edit, :update] do
    member do
      get :show_followings
      get :show_followeds
      get :show_great_posts
      get :show_posts
      get :show_collections
      get :show_comments
      get :show_voting_ups
      get :show_voting_downs

      get :show_received_secrets
      get :show_sent_secrets
      get :show_messages
      get :show_sent_invitations

      get :change_words
      get :change_avatar
      get :change_password

      put :update_words
      put :update_avatar
      put :update_password
    end
  end

  get '/signup/(:invitation_token)' => 'users#new'
  get '/signin' => 'sessions#new'
  delete '/signout' => 'sessions#destroy'
  resources :sessions, only: [:new, :create, :destroy]

  resources :following_relationships, only: [:create, :destroy]
  resources :collecting_relationships, only: [:create, :destroy]
  resources :voting_up_relationships, only: :create
  resources :voting_down_relationships, only: :create

  resources :comments, except: [:index, :show, :new] do
    member do
      get :show_total_comments
      get :show_voting_ups
      get :show_voting_downs
    end
  end

  resources :secrets, only: [:new, :create, :destroy]
  resources :messages, only: :destroy
  resources :invitations, only: :create

  get '/email_confirm/:confirm_token' => 'email_confirm#new', as: :email_confirm
  post '/email_confirm' => 'email_confirm#create'
  resources :password_resets, only: [:new, :create, :edit, :update]

  namespace :admin do
    root to: 'admin/node_groups#index'

    resources :node_groups, except: [:show, :destroy]
    resources :nodes, except: [:index, :show, :destroy]
  end
end
