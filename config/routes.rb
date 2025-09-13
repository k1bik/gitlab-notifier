Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"

  post "merge_request_labels_gitlab_webhook", to: "merge_request_labels_gitlab_webhook#create"
  post "deployment_events_gitlab_webhook", to: "deployment_events_gitlab_webhook#create"

  namespace :api do
    resources :user_mappings, only: %i[create]
    resources :observable_labels, only: %i[create destroy]
  end
end
