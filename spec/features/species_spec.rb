require "rails_helper"

RSpec.feature "Species", type: :feature do
  describe "/species" do
    before :each do
      visit species_path
    end

    it "lists all of the species" do
      Species.all.each do |pkmn|
        expect(page).to have_selector(".name", text: pkmn.name)
      end
    end
  end
end
