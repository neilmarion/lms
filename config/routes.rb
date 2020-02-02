Lms::Engine.routes.draw do
  resources :loans do
    member do
      patch :create_custom_payment
      patch :delete_custom_payment
      get :show_custom_payment
    end
    resources :actual_events, controller: "loans/actual_events"
  end
end
