Rails.application.routes.draw do
  root "pages#index"
  %w[home index].each { |r| get "/#{r}", to: redirect("/") }
end
