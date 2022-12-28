class UsersController < ApplicationController
  skip_forgery_protection # Using Google API token verification

  # POST /login/submit
  def login
    parse_token params["credential"]

    if (user = User.find_by(google_id: @token.user_id)).blank?
      # Take user to registration page to fill in their username
      redirect_to register_url(credential: params["credential"])
    else
      # Log in
      cookies.encrypted[:google_id] = @token.user_id
    end
  end

  # GET /register
  def register
    parse_token params["credential"]
  end

private

  def parse_token(credential)
    begin
      @token = GoogleSignIn::Identity.new(credential)
    rescue GoogleSignIn::Identity::ValidationError
      redirect_to root_url, notice: "Authentication failed."
      puts "User authentication failed. POST params:"
      p params # TODO: Log this
      return
    end
  end
end
