class ApplicationController < ActionController::Base
  before_action :set_current_user

  private

  def set_current_user
    @current_user = User.find_by_google_id cookies.encrypted[:google_id]
  end
end
