class UsersController < ApplicationController
  skip_forgery_protection # Using Google API token verification
  before_action :parse_token

  # POST /login/submit
  def login
    if (user = User.find_by(google_id: @token.user_id)).blank?
      # Take user to registration page to fill in their username
      redirect_post register_url(credential: params["credential"])
    else
      log_in
    end
  end

  # POST /register
  def register
  end

  # POST /register/submit
  def create
    @user = User.new(
      username: params["username"],
      email: params["email"],
      google_id: @token.user_id
    )

    if @user.save
      puts "SUCCESS"
    else
      puts "PHAIL"
    end

    log_in
  end

private

  # Parse Google JWT using google_sign_in gem
  #
  # We need to do this everywhere because we can't trust the user to pass
  # around the raw user_id
  #
  # @param credential [String] Google sign-in JWT
  # @return [GoogleSignIn::Identity] parsed token
  def parse_token
    begin
      @token = GoogleSignIn::Identity.new(params["credential"])
    rescue GoogleSignIn::Identity::ValidationError
      redirect_to root_url, notice: "Authentication failed."
      puts "User authentication failed. POST params:"
      p params # TODO: Log this
      return
    end
  end

  def log_in
    cookies.encrypted[:google_id] = @token.user_id
    redirect_to root_url, notice: "Login successful."
  end
end
