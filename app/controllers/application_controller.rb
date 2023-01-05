class ApplicationController < ActionController::Base
  before_action :set_current_user, :turbo_request_variant

  private

  def set_current_user
    @current_user = User.find_by_google_id cookies.encrypted[:google_id]
  end

  def turbo_request_variant
    request.variant = :turbo_frame if turbo_frame_request?
  end
end
