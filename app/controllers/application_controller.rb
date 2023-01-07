class ApplicationController < ActionController::Base
  before_action :init_globals, :set_current_user, :turbo_request_variant

  private

  def init_globals
    # Navigation links
    @nav_links = [
      ["school", trainees_path, "Trainees"],
      ["fitness_center", species_path, "EV Yields"]
    ]
  end

  def set_current_user
    @current_user = User.find_by_google_id cookies.encrypted[:google_id]
  end

  def turbo_request_variant
    request.variant = :turbo_frame if turbo_frame_request?
  end
end
