# frozen_string_literal: true

class SpeciesController < ApplicationController
  # GET /species
  def index
    @search_results = Species.search params, cookies[:generation], show_all: true
  end
end
