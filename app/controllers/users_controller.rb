class UsersController < ApplicationController
  # skip_forgery_protection # Using Google API token verification
  skip_before_action :verify_authenticity_token, only: %i[login register]
  before_action :parse_token, only: %i[login create register]

  # GET /users/:username
  def show
    # This is the user being displayed on the profile page, not necessarily
    # the logged in user.
    @display_user = User.find_by username: params[:username]
    render "errors/not_found", status: 404 unless @display_user
  end

  # PATCH /users/:username
  def update
    @user = User.find_by username: params[:username]

    if @current_user != @user
      return redirect_to user_path(@user), notice: "Authentication failed."
    end

    @user.email = params[:user][:email]

    notice = @user.save ? "Email updated." : "There was a problem updating your email."
    redirect_to user_path(@user), notice: notice
  end

  # DELETE /users/:username
  def destroy
    # TODO. Issue #16
  end

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
    params["username"].strip!
    params["email"].strip!

    @user = User.new(
      username: params["username"],
      email: params["email"],
      google_id: @token.user_id
    )

    if @user.save
      @found_user = @user
      log_in
    else
      flash[:notice] = "Registration failed: #{@user.errors.full_messages.join ', '}"
      redirect_post register_path(credential: params["credential"])
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
      return redirect_to root_url, notice: "Authentication failed."
    end

    @found_user = User.find_by_google_id @token.user_id
  end

  # Log in the user from @token (must be loaded from params w/ parse_token)
  def log_in
    cookies.permanent.encrypted[:google_id] = @token.user_id
    redirect_to trainees_url, notice: "Logged in as #{@found_user.username}."
  end
end
