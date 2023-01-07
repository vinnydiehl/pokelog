Rails.application.routes.draw do
  root "pages#index"

  %w[home index register].each { |r| get "/#{r}", to: redirect("/") }

  post "/login/submit", to: "users#login"
  post "/register", to: "users#register"
  post "/register/submit", to: "users#create"
  get "/logout", to: "users#logout"

  get "/trainees", to: "trainees#index"
  get "/species", to: "species#index"

  if Rails.env.test?
    get "/login/submit", to: "users#login"
  end
end
