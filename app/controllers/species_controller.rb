class SpeciesController < ApplicationController
  # GET /species
  def index
    @search_results = Species.search params, true
  end
end
