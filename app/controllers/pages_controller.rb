# frozen_string_literal: true

class PagesController < ApplicationController
  # GET /
  def index
    if request.path == "/" && @current_user.present?
      redirect_to trainees_path
    end
  end

  # GET /about
  def about
    @commit = ENV["HEROKU_SLUG_COMMIT"] || `git rev-parse HEAD`.strip
  end
end
