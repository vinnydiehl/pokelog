Rails.application.routes.draw do
  root "pages#index"

  %w[home index].each { |r| get "/#{r}", to: "pages#index" }
  get "/register", to: redirect("/")

  # Need to manually define #new route since these are parsed from the top-down
  get "/trainees/new", to: "trainees#new"
  get "/trainees/:ids", to: "trainees#show", as: "trainee_show"
  get "/trainees/:ids/new", to: "trainees#add_new"
  resources :trainees

  post "/login/submit", to: "users#login"
  post "/register", to: "users#register"
  post "/register/submit", to: "users#create"
  get "/logout", to: "users#logout"

  get "/species", to: "species#index"

  {
    400 => "bad_request",
    404 => "not_found",
    422 => "unprocessable_entity",
    500 => "internal_server_error"
  }.each do |code, view|
    match "/#{code}", to: "errors##{view}", via: :all
  end

  if Rails.env.test?
    get "/login/submit", to: "users#login"
  end
end
