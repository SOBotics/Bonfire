Rails.application.routes.draw do
  devise_for :users

  root :to => 'posts#index'

  get 'posts', :to => 'posts#index'
  post 'posts/new', :to => 'posts#create'
  get 'posts/:id', :to => 'posts#show'
  get 'posts/:id/edit', :to => 'posts#edit'
  patch 'posts/:id/edit', :to => 'posts#update'
  delete 'posts/:id', :to => 'posts#destroy'
  get 'posts/:question_id/flag_options', :to => 'posts#flag_options'
  post 'posts/:question_id/flag', :to => 'posts#cast_flag'

  get 'reasons', :to => 'reasons#index'
  get 'reasons/:id', :to => 'reasons#show'
  get 'reasons/:id/edit', :to => 'reasons#edit'
  patch 'reasons/:id/edit', :to => 'reasons#update'
  delete 'reasons/:id', :to => 'reasons#destroy' 

  get 'bots', :to => 'authorized_bots#index'
  get 'bots/new', :to => 'authorized_bots#new'
  post 'bots/new', :to => 'authorized_bots#create'
  delete 'bots/:id', :to => 'authorized_bots#destroy'

  get 'apps', :to => 'api_keys#index'
  get 'apps/admin', :to => 'api_keys#admin_list'
  get 'apps/new', :to => 'api_keys#new'
  post 'apps/new', :to => 'api_keys#create'
  get 'apps/:id/edit', :to => 'api_keys#edit'
  patch 'apps/:id/edit', :to => 'api_keys#update'
  delete 'apps/:id', :to => 'api_keys#destroy'

  get 'users', :to => 'users#index'
  post 'users/:id/promote', :to => 'users#promote'
  post 'users/:id/demote', :to => 'users#demote'
  get 'users/:id', :to => 'users#show'
  post 'users/:user_id/deauth', :to => 'se_auth#deauth'

  get 'authentication/initiate', :to => 'se_auth#initiate'
  get 'authentication/upgrade', :to => 'se_auth#upgrade'
  post 'authentication/redirect', :to => 'se_auth#redirect'
  get 'authentication/target', :to => 'se_auth#target'
  get 'authentication/complete', :to => 'se_auth#already_done'
  get 'authentication/login_target', :to => 'se_auth#login_target'

  get 'search', :to => 'search#results'

  get 'graphs', :to => 'graphs#index'
  get 'graphs/posts_by_hour', :to => 'graphs#posts_by_hour'
  get 'graphs/post_statuses', :to => 'graphs#post_statuses'
  get 'graphs/reason_post_status_types', :to => 'graphs#reason_post_status_types'

  get 'review', :to => 'review#index'
  get 'review/close', :to => 'review#close_review'
  get 'review/seed', :to => 'review#seed_review'
  post 'review/create', :to => 'review#create'
  get 'review/history', :to => 'review#history'

  get 'api/posts/by_url', :to => 'api#posts_by_url'
  get 'api/reasons/:ids', :to => 'api#reasons_by_id'
end
