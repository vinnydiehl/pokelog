class UsersController < ApplicationController
  before_action :set_user, only: %i[show edit update destroy]
  skip_forgery_protection # Using Google API token verification

  # GET /users or /users.json
  def index
    @users = User.all
  end

  # GET /users/1 or /users/1.json
  def show
  end

  # GET /users/new
  def new
    @user = User.new
  end

  # GET /users/1/edit
  def edit
  end

  # POST /login/submit
  def login
    begin
      token = GoogleSignIn::Identity.new(params["credential"])
    rescue GoogleSignIn::Identity::ValidationError
      redirect_to root_url, notice: "Authentication failed."
      puts "User authentication failed. POST params:"
      p params # TODO: Log this
      return
    end

    if (user = User.find_by(google_id: token.user_id)).blank?
      # Take user to registration page to fill in their username
    end

    # Log in
    cookies.encrypted[:google_id] = token.user_id
  end

  # PATCH/PUT /users/1 or /users/1.json
  def update
    respond_to do |format|
      if @user.update(user_params)
        format.html { redirect_to user_url(@user), notice: "User was successfully updated." }
        format.json { render :show, status: :ok, location: @user }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1 or /users/1.json
  def destroy
    @user.destroy

    respond_to do |format|
      format.html { redirect_to users_url, notice: "User was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def user_params
      params.require(:user).permit(:email, :username, :password_digest)
    end
end
