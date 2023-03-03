class ApplicationController < ActionController::Base
  before_action *%i[init_globals set_current_user turbo_request_variant clean_cookies]

  private

  def init_globals
    # Navigation links
    @nav_links = [
      ["school", trainees_path, "Trainees"],
      ["fitness_center", species_path, "EV Yields"],
      ["info", "/about", "About Us"]
    ]
  end

  def set_current_user
    @current_user = User.find_by_google_id cookies.encrypted[:google_id]
  end

  def turbo_request_variant
    request.variant = :turbo_frame if turbo_frame_request?
  end

  def clean_cookies
    if helpers.logged_in?
      # Detect and remove old trainee EV goal cookies
      cookies.each do |name, value|
        if name.starts_with?("trainee_") &&
           @current_user.trainees.where(id: name.split("_")[1].to_i).none?
          cookies.delete name
        end
      end
    end
  end
end
