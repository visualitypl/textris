Rails.application.routes.draw do
  resources :users, :only => [:index, :new, :create]

  root :to => 'users#new'
end
