Lms::Engine.routes.draw do
  resources :loans do
    resources :actual_events, controller: "loans/actual_events"
  end
end
