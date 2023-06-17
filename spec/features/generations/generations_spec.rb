# frozen_string_literal: true

# With no generation selected, Pokémon from all generations are shown in the
# search results, and the behavior of everything else is set to the most recent
# generation by default. This core behavior tested throughout the rest of the
# test suite. This file is only for cases where the generation has been changed.

require "rails_helper"

RSpec.feature "generations:", type: :feature, js: true do
  context "with one trainee" do
    before do
      launch_new_blank_trainee
    end

    # Basic funtionality tests to ensure that a feature isn't broken in any generation
    (3..9).each do |gen|
      context "generation #{gen}:" do
        before { set_generation gen }

        it "kill buttons work" do
          fill_in "Search", with: "Shellder" # 1 Def
          find("#species_090").click
          wait_for :def_ev, 1

          expect(Trainee.first.def_ev).to eq 1
        end

        it "goals work" do
          set_goal :hp, 150
          set_ev :hp, 149
          click_away
          sleep 0.5

          expect(page).to have_selector "#goal-alert", visible: :visible
        end
      end
    end

    # Unavailable items
    { 3 => POWER_ITEMS, 7 => [:macho_brace] }.each do |gen, items|
      context "generation #{gen}:" do
        items.each do |item|
          it "the #{item.to_s.humanize.downcase} is disabled" do
            set_generation gen

            check_with_refresh do
              expect(page).to have_field "trainee_item_#{item}", visible: :hidden, disabled: true
            end
          end
        end
      end

      (3..9).except(gen).each do |available_gen|
        context "generation #{available_gen}:" do
          items.each do |item|
            it "the #{item.to_s.humanize.downcase} is enabled" do
              set_generation available_gen

              check_with_refresh do
                expect(page).to have_field "trainee_item_#{item}", visible: :hidden, disabled: false
              end
            end
          end
        end
      end

      context "if you have an unavilable item set and switch to gen #{gen}" do
        it "sets the item to none" do
          set_held_item items.first
          set_generation gen
          wait_for :item, nil

          expect(Trainee.first.item).to be_nil
        end
      end
    end

    # Individual stat caps
    [[(3..5), 255],
     [(6..9), 252]].each do |range, max_evs|
      range.each do |gen|
        context "generation #{gen}:" do
          before do
            set_generation gen
          end

          test_max_evs_per_stat max_evs
        end
      end
    end

    # Pokérus
    [[(3..8), true ],
     [[9],    false]].each do |range, pokerus_available|
      range.each do |gen|
        context "generation #{gen}:" do
          before do
            set_generation gen
            open_consumables_menu
          end

          it "the Pokérus switch is#{pokerus_available ? '' : ' not'} available" do
            if pokerus_available
              expect(page).to have_selector ".pokerus.switch"
            else
              expect(page).not_to have_selector ".pokerus.switch"
            end
          end
        end
      end
    end

    # Search filters
    describe "species search" do
      [[3, "Deoxys", "Turtwig"],
       [4, "Arceus", "Victini"],
       [5, "Genesect", "Chespin"],
       [6, "Volcanion", "Rowlet"],
       [7, "Melmetal", "Grookey"],
       [8, "Enamorus", "Sprigatito"],
       [9, "Sprigatito", "Enamorus"]].each do |gen, included, not_included|
        context "generation #{gen}:" do
          before do
            set_generation gen
          end

          it "includes #{included}" do
            fill_in "Search", with: included

            expect(find ".results").to have_content included
          end

          it "does not include #{not_included}" do
            fill_in "Search", with: not_included

            expect(find ".results").not_to have_content not_included
          end
        end
      end
    end
  end

  context "with multiple trainees" do
    before do
      launch_multi_trainee
    end

    # This problem was happening on multi and single trainees, but was worse here
    it "sets the generation reliably, multiple times in a row" do
      set_generation 3
      set_generation 4
      set_generation 5
    end
  end
end
