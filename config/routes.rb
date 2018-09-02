Rails.application.routes.draw do
  resources :repo, only: [:index] do
    collection do
      post :index
      get :stat
    end
  end

  root to: 'repo#index'
end
