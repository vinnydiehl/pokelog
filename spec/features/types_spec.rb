# frozen_string_literal: true

require "rails_helper"

TYPE_TEST_CASES = {
  "009" => %w[water],           # Blastoise
  "020-a" => %w[dark normal],   # Raticate-Alolan
  "249" => %w[psychic flying],  # Lugia
  "861" => %w[dark fairy],      # Grimmsnarl
  "1008" => %w[electric dragon] # Miraidon
}.freeze

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

  describe "the trainee partial" do
    before :each do
      create_user

      TYPE_TEST_CASES.each do |id, _|
        Trainee.new(user: User.first, species_id: id).save!
      end
    end

    TYPE_TEST_CASES.each do |id, types|
      describe "species ##{id}" do
        before :each do
          visit trainee_path(Trainee.find_by species_id: id)
        end

        types.each do |type|
          it "is type #{type}" do
            expect(find ".sprite-and-types").to have_selector ".#{type}"
          end
        end
      end
    end
  end
end
