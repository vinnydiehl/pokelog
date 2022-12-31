Rails.application.routes.draw do
  root "pages#index"

  %w[home index].each { |r| get "/#{r}", to: redirect("/") }
  %w[dex pokedex species].each { |r| get "/#{r}", to: "species#index" }

  resources :teams
  resources :trainees

  post "/login/submit", to: "users#login"
  post "/register", to: "users#register"
  post "/register/submit", to: "users#create"
  get "/logout", to: "users#logout"
end
