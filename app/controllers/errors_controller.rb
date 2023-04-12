# frozen_string_literal: true

class ErrorsController < ApplicationController
  # GET /400
  def bad_request
    render status: 400
  end

  # GET /404
  def not_found
    render status: 404
  end

  # GET /422
  def unprocessable_entity
    render status: 422
  end

  # GET /500
  def internal_server_error
    render status: 500
  end
end
