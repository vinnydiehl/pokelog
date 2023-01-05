class SpeciesController < ApplicationController
  def index
    @search_results = (query = params[:q]).present? ?
      Species.all.select { |pkmn| pkmn.name =~ /.*#{query}.*/i } :
      Species.all
  end
end
