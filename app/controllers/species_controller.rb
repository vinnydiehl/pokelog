class SpeciesController < ApplicationController
  # GET /species
  def index
    @search_results = (query = params[:q]).present? ?
      Species.all.select { |pkmn| pkmn.name.downcase.include? query.downcase } :
      Species.all
  end
end
