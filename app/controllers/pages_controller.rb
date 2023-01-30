class PagesController < ApplicationController
  def index
    if request.path == "/" && !@current_user.blank?
      return redirect_to trainees_path
    end
  end

  def about
    @commit = ENV["HEROKU_SLUG_COMMIT"] || `git rev-parse HEAD`.strip
  end
end
