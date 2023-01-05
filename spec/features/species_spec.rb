require "rails_helper"

RESULTS_DIV = ".results"

# Checks the yields table for the presence of every 50 Pokémon in the
# data/species.yml data (checking them all takes forever)
#
# @param except [Array] Pokémon to exclude from search
# @return true if all Pokémon checked are present, false otherwise
def check_every_50(except: nil)
  (table = find RESULTS_DIV).has_content?(Species.all.first.name) &&
  Species.all.each_slice(50).map(&:last).all? do |pkmn|
    (except && except.include?(pkmn.name)) || table.has_content?(pkmn.name)
  end
end

def exec_check_every_50
  it "lists all of the species" do
    expect(check_every_50).to be true
  end
end

RSpec.feature "species:", type: :feature do
  describe "yields table" do
    before :each do
      visit species_path
    end

    describe "search bar" do
      context "on page load" do
        exec_check_every_50

        context "with manually entered GET query" do
          query = "ven"

          before :each do
            visit species_path(q: query)
          end

          it "should be pre-filled" do
            expect(page).to have_field "Search", with: query
          end
        end
      end

      context "after query has been erased" do
        before :each do
          fill_in "Search", with: "ven"
          fill_in "Search", with: ""
        end

        exec_check_every_50
      end

      {
        "bee": %w[Beedrill Combee Ribombee Orbeetle],
        "ven": %w[Venusaur Venonat Venomoth Venipede Trevenant],
        # Test case insensitivity
        "VENUSaur": %w[Venusaur]
      }.each do |query, expected_results|
        context %[with query "#{query}"] do
          before :each do
            fill_in "Search", with: query
          end

          it "contains the expected results", js: true do
            table = find RESULTS_DIV
            expected_results.each do |result|
              expect(table).to have_content result
            end
          end

          it "does not contain anything but the expected results", js: true do
            expect(check_every_50 except: expected_results).to be false
          end
        end
      end
    end
  end
end
