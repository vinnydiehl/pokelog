require "rails_helper"

TYPE_TEST_CASES = {
  "009" => %w[water],           # Blastoise
  "020-a" => %w[dark normal],   # Raticate-Alolan
  "249" => %w[psychic flying],  # Lugia
  "861" => %w[dark fairy],      # Grimmsnarl
  "1008" => %w[electric dragon] # Miraidon
}

RSpec.feature "types:", type: :feature do
  describe "the species partial" do
    before :each do
      visit species_path
    end

    TYPE_TEST_CASES.each do |id, types|
      describe "species #{id}" do
        types.each do |type|
          it "is type #{type}" do
            expect(find "#species_#{id}").to have_selector ".#{type}"
          end
        end
      end
    end
  end
end
