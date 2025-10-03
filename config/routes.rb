Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  post "merge_request_labels_gitlab_webhook", to: "merge_request_labels_gitlab_webhook#create"
  post "deployment_events_gitlab_webhook", to: "deployment_events_gitlab_webhook#create"
  post "interactive_messages_slack_webhook", to: "interactive_messages_slack_webhook#create"

  namespace :api do
    resources :user_mappings, only: %i[create]
    resources :observable_labels, only: %i[create]
    resources :messages, only: %i[create]
  end
end
