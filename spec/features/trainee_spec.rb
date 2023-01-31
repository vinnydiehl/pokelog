require "rails_helper"

require_relative "support/trainee_spec_helpers"

RSpec.feature "trainees#show: ", type: :feature do
  context "with one trainee in the party" do
    context "with a blank trainee" do
      before :each do
        create_user
        log_in

        trainee = Trainee.new(user: User.first)
        trainee.save!

        visit trainee_path(trainee)
      end

      test_server_interaction

      # Stats need to be 0, nature needs to be "" for compatibility
      test_trainee_ui nil, STATS.map { |s| {s.to_sym => 0} }.
        append({nature: ""}).inject(&:merge)

      context "with 254 HP EVs", js: true do
        before :each do
          fill_in "trainee_hp_ev", with: (@original = 254)
          wait_for :hp_ev, @original
        end

        describe "a 2 HP kill button" do
          before :each do
            # Pidgeotto
            find("#species_017").click
            sleep 1
          end

          it "doesn't increment the HP EV" do
            expect(find("#trainee_hp_ev").value).to eq @original.to_s
            expect(Trainee.first.hp_ev).to eq @original
          end
        end
      end

      # Edge case behavior, see issue #1
      context "with 509 total EVs", js: true do
        before :each do
          # Set everything except HP to 100
          STATS[1..-1].each do |stat|
            fill_in "trainee_#{stat}", with: 100
          end
          wait_for STATS.last, 100

          fill_in "trainee_#{STATS.first}", with: (@original = 9)
          wait_for STATS.first, @original
        end

        context "when you get a kill w/ 1 Def, 1 Sp.D" do
          before :each do
            # Blastoise
            find("#species_008").click
            wait_for :def_ev, 101
          end

          it "gives you 1 Def" do
            expect(find("#trainee_def_ev").value).to eq "101"
            expect(Trainee.first.def_ev).to eq 101
          end

          it "gives you 0 Sp.D" do
            expect(find("#trainee_spd_ev").value).to eq "100"
            expect(Trainee.first.spd_ev).to eq 100
          end
        end

        context "when you get a kill w/ 1 Atk while holding a Power Band (4 Sp.D)" do
          before :each do
            find("span", text: "Power Band").click
            wait_for :item, "power_band"

            # Ekans
            find("#species_023").click
            wait_for :atk_ev, 101
          end

          it "gives you 1 Atk" do
            expect(find("#trainee_atk_ev").value).to eq "101"
            expect(Trainee.first.atk_ev).to eq 101
          end

          it "gives you 0 Sp.D" do
            expect(find("#trainee_spd_ev").value).to eq "100"
            expect(Trainee.first.spd_ev).to eq 100
          end
        end
      end

      context "with 510 total EVs", js: true do
        before :each do
          # Set everything except HP to 100
          STATS[1..-1].each do |stat|
            fill_in "trainee_#{stat}", with: 100
          end
          wait_for STATS.last, 100

          fill_in "trainee_#{STATS.first}", with: (@original = 10)
          wait_for STATS.first, @original
        end

        it "turns the input borders green" do
          # Wait for color transition
          sleep 0.5

          find_all(".ev-input").each do |input|
            expect(input.style("border-color").values.first).to eq "rgb(0, 128, 0)"
          end
        end

        it "keeps the borders green on reload" do
          visit current_path
          find_all(".ev-input").each do |input|
            expect(input.style("border-color").values.first).to eq "rgb(0, 128, 0)"
          end
        end

        context "if you set the total back to 509" do
          before :each do
            fill_in "trainee_#{STATS.first}", with: (@original = 9)
            wait_for STATS.first, @original
          end

          it "turns the input borders black" do
            # Wait for color transition
            sleep 0.5
            find_all(".ev-input").each do |input|
              expect(input.style("border-color").values.first).to eq "rgb(0, 0, 0)"
            end
          end

          it "keeps the borders black on reload" do
            visit current_path
            find_all(".ev-input").each do |input|
              expect(input.style("border-color").values.first).to eq "rgb(0, 0, 0)"
            end
          end

          context "if you try to use a kill button to go 2 over" do
            before :each do
              # Nidoqueen for 3 HP
              find("#species_031").click
              # Can't use wait_for because the server shouldn't update
              sleep 1
            end

            it "doesn't update the input" do
              expect(find("#trainee_#{STATS.first}").value).to eq @original.to_s
            end

            it "doesn't update the server" do
              expect(Trainee.first.send STATS.first).to eq @original
            end
          end
        end

        context "if you try to enter 511 total through the inputs" do
          before :each do
            fill_in "trainee_#{STATS.first}", with: 11
            # Can't use wait_for because the server shouldn't update
            sleep 1
          end

          it "turns the input borders red" do
            find_all(".ev-input").each do |input|
              expect(input.style("border-color").values.first).to eq "rgb(255, 0, 0)"
            end
          end

          it "doesn't update the server" do
            expect(Trainee.first.send STATS.first).to eq @original
          end
        end

        context "if you try to use a kill button to go 1 over" do
          before :each do
            # Caterpie for 1 HP
            find("#species_010").click
            sleep 1
          end

          it "doesn't update the input" do
            expect(find("#trainee_#{STATS.first}").value).to eq @original.to_s
          end

          it "doesn't update the server" do
            expect(Trainee.first.send STATS.first).to eq @original
          end
        end
      end

      TEST_KILL_BUTTONS.each do |id, data|
        context "when using the #{data[:name]} kill button", js: true do
          [true, false].each do |pokerus|
            context "with#{pokerus ? "" : "out"} Pokérus" do
              ([nil] + ITEMS).each do |item|
                item_name = (item || "No Item").titleize

                context "while holding #{item_name}" do
                  before :each do
                    # Calculate expected values based off Pokérus/held item
                    data.delete :name
                    @expected = calculate_final_evs item, pokerus, data

                    # Click the necessary toggles
                    if pokerus
                      find(".pokerus label").click
                      wait_for :pokerus, pokerus
                    end
                    find("span", text: item_name).click
                    wait_for :item, item

                    # Click the kill button
                    find("##{id}").click
                    # Use a stat that we know we're changing to wait for DB
                    wait_stat = data.keys.first
                    wait_for :"#{wait_stat}_ev", @expected[wait_stat]
                  end

                  it "sets the EVs in the database" do
                    @expected.each do |stat, value|
                      expect(Trainee.first.send "#{stat}_ev").to eq value
                    end
                  end

                  it "changes the values in the EV inputs" do
                    @expected.each do |stat, value|
                      value = value.zero? ? "" : value.to_s
                      expect(find_field("trainee_#{stat}_ev").value).to eq value
                    end
                  end
                end
              end
            end
          end
        end
      end
    end

    context "with a populated trainee" do
      context "while logged in" do
        TEST_TRAINEES.each do |display_name, attrs|
          describe "test trainee: #{attrs[:nickname]}" do
            before :each do
              create_user
              log_in

              trainee = Trainee.new user: User.first, **attrs
              trainee.save!

              visit trainee_path(trainee)
            end

            # Don't run server tests for the species that's already loaded
            test_server_interaction if attrs[:species_id] != SINGLE_ATTRS[:species_id]

            test_trainee_ui display_name, attrs
          end
        end
      end

      context "while logged out" do
        it "displays a static page" do
          create_user

          display_name, attrs = TEST_TRAINEES.first
          trainee = Trainee.new(user: User.first, **attrs)
          trainee.save!
          visit trainee_path(trainee)

          # Make sure held item is selected
          expect(page).to have_field "trainee_item_#{attrs[:item]}",
            checked: true, disabled: true
          # Make sure all items are disabled
          ([""] + ITEMS.map { |s| "_#{s}" }).each do |item|
            expect(page).to have_field "trainee_item#{item}", disabled: true
          end

          expect(page).to have_field "trainee_species", with: display_name,
                                                        disabled: true

          %w[nickname level nature].each do |field|
            expected_value = attrs[field.to_sym]
            expect(page).to have_field "trainee_#{field}", with: expected_value,
                                                           disabled: true
          end

          STATS.each do |stat|
            expected_value = attrs[stat].zero? ? nil : attrs[stat]
            expect(find("#trainee_#{stat}[value='#{expected_value}']")[:disabled]).to eq "disabled"
          end
        end

        it "does not display the kill search" do
          expect(page).not_to have_selector("#kill-search")
        end

        it "does not display the delete button" do
          expect(page).not_to have_selector(".delete-btn")
        end
      end
    end
  end
end
