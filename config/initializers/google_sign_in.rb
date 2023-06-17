# frozen_string_literal: true

Rails.application.configure do
  config.google_sign_in.client_id = ENV.fetch("GOOGLE_OAUTH2_ID")
  config.google_sign_in.client_secret = ENV.fetch("GOOGLE_OAUTH2_SECRET")
  config.google_sign_in.root = "login/submit"
end
