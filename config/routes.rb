Rails.application.routes.draw do
  resources :repo, only: [:index] do
    collection do
      get :diplom
      post :diploms_archive
    end
  end

  root to: 'repo#index'
end
