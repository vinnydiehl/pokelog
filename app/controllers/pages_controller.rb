class PagesController < ApplicationController
  def index
    if request.path == "/" && !@current_user.blank?
      return redirect_to trainees_path
    end
  end
end
