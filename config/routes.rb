Rails.application.routes.draw do
  resources :teams
  resources :trainees
  resources :users
  root "pages#index"
  %w[home index].each { |r| get "/#{r}", to: redirect("/") }
end
