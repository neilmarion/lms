Lms::Engine.routes.draw do
  resources :loans do
    member do
      patch :create_custom_payment
      patch :delete_custom_payment
      get :show_custom_payment
      get :change_date_pointer
    end
    resources :actual_events, controller: "loans/actual_events"
  end
end
