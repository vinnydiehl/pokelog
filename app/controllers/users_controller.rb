class UsersController < ApplicationController
  skip_forgery_protection # Using Google API token verification
  before_action :parse_token, only: %i[login create register]

  # POST /login/submit
  def login
    if @found_user.blank?
      # Take user to registration page to fill in their username
      redirect_post register_path(credential: params["credential"])
    else
      log_in
    end
  end

  # POST /register/submit
  def create
    @user = User.new(
      username: params["username"],
      email: params["email"],
      google_id: @token.user_id
    )

    if @user.save
      @found_user = @user
      log_in
    else
      redirect_to root_url, notice: "Registration failed."
    end
  end

  # GET /logout
  def logout
    cookies.delete :google_id
    redirect_to root_url, notice: "Logged out."
  end

  private

  # Parse Google JWT using google_sign_in gem
  #
  # We need to do this everywhere because we can't trust the user to pass
  # around the raw user_id. Uses POST params to set @token and, if the
  # user exists in the database, @found_user.
  def parse_token
    begin
      @token = GoogleSignIn::Identity.new(params["credential"])
    rescue GoogleSignIn::Identity::ValidationError
      redirect_to root_url, notice: "Authentication failed."
      puts "User authentication failed. POST params:"
      p params # TODO: Log this
      return
    end

    @found_user = User.find_by_google_id @token.user_id
  end

  # Log in the user from @token (must be loaded from params w/ parse_token)
  def log_in
    cookies.encrypted[:google_id] = @token.user_id
    redirect_to trainees_url, notice: "Logged in as #{@found_user.username}."
  end
end
