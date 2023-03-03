# With no generation selected, Pokémon from all generations are shown in the
# search results, and the behavior of everything else is set to the most recent
# generation by default. This core behavior tested throughout the rest of the
# test suite. This file is only for cases where the generation has been changed.

require "rails_helper"

RSpec.feature "generations:", type: :feature, js: true do
  context "with one trainee" do
    before :each do
      launch_new_blank_trainee
    end

    # Unavailable items
    {3 => POWER_ITEMS, 7 => [:macho_brace]}.each do |gen, items|
      context "generation #{gen}:" do
        items.each do |item|
          it "the #{item.to_s.humanize.downcase} is disabled" do
            set_generation gen

            check_with_refresh do
              expect(page).to have_field "trainee_item_#{item}", visible: false, disabled: true
            end
          end
        end
      end

      (3..9).except(gen).each do |gen|
        context "generation #{gen}:" do
          items.each do |item|
            it "the #{item.to_s.humanize.downcase} is enabled" do
              set_generation gen

              check_with_refresh do
                expect(page).to have_field "trainee_item_#{item}", visible: false, disabled: false
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

          expect(Trainee.first.item).to be nil
        end
      end
    end

    # Individual stat caps
    [[(3..5), 255],
     [(6..9), 252]].each do |range, max_evs|
      range.each do |gen|
        context "generation #{gen}:" do
          before(:each) do
            set_generation gen
          end

          test_max_evs_per_stat max_evs
        end
      end
    end

    # Power items
    [[(4..6), 4],
     [(7..9), 8]].each do |range, boost|
      range.each do |gen|
        context "generation #{gen}:" do
          before(:each) do
            set_generation gen
            open_consumables_menu
          end

          POWER_ITEMS.each { |item| test_power_item_boost item, boost }
        end
      end
    end

    # Vitamins
    [[(3..7), [[  0, 10 ],
               [ 95, 100],
               [101, 101]]],
     [(8..9), [[ 95, 105],
               [250, 252]]]].each do |range, test_cases|
      range.each do |gen|
        context "generation #{gen}:" do
          before(:each) do
            set_generation gen
            open_consumables_menu
          end

          test_consumables vitamins: test_cases
        end
      end
    end

    # Wings/Feathers Disabled?
    [[(3..4), false],
     [(5..9), true ]].each do |range, availability|
      range.each do |gen|
        context "generation #{gen}:" do
          before(:each) do
            set_generation gen
            open_consumables_menu
          end

          it "feathers are#{availability ? '' : ' not'} available" do
            expect(page).to have_selector(
              ".consumables-buttons .btn#{availability ? '' : '.disabled'}")
          end
        end
      end
    end

    # Wings/Feathers Name
    [[(3..7), "Wings"   ],
     [(8..9), "Feathers"]].each do |range, name|
      range.each do |gen|
        context "generation #{gen}:" do
          before(:each) do
            set_generation gen
            open_consumables_menu
          end

          it "they are called #{name.downcase}" do
            expect(page).to have_selector ".items-menu h5", text: name
          end
        end
      end
    end

    # Berries
    [[             [4], [[252, 100],
                         [109, 99 ],
                         [ 99, 89 ],
                         [  5, 0  ]]],
     [(3..9).except(4), [[252, 242],
                         [100, 90 ],
                         [  5, 0  ]]]].each do |range, test_cases|
      range.each do |gen|
        context "generation #{gen}:" do
          before(:each) do
            set_generation gen
            open_consumables_menu
          end

          test_consumables berries: test_cases
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
            before(:each) do
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
    before :each do
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
