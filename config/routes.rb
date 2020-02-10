Lms::Engine.routes.draw do
  resources :loans do
    member do
      get :change_date
      get :table
    end
  end
end
