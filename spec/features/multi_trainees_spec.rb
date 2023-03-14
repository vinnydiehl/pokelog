require "rails_helper"

RSpec.feature "trainees#show:", type: :feature do
  context "with multiple trainees in the party", js: true do
    before :each do
      launch_multi_trainee
    end

    TEST_TRAINEES.each do |display_name, attrs|
      test_trainee_ui display_name, attrs
    end

    TEST_TRAINEES.each do |_, attrs|
      context "if you clear all inputs for #{attrs[:nickname]}" do
        before :each do
          @id = find_id attrs
        end

        STATS.each do |stat|
          it "sets #{stat} to 0 on the server" do
            within "#trainee_#{@id}" do
              set_ev stat, 0, attrs: attrs

              expect(find_trainee(attrs).send stat).to eq 0
            end
          end
        end

        %w[nickname species level].each do |field|
          it "sets #{field} nil on the server" do
            within "#trainee_#{@id}" do
              fill_in "trainee_#{field}", with: ""
              click_away within: :trainee_info

              expect(find_trainee(attrs).send field).to be_blank
            end
          end
        end

        it "updates Pokérus status" do
          within "#trainee_#{@id}" do
            expected_status = !find_trainee(attrs).pokerus
            find(".pokerus label").click
            wait_for :pokerus, expected_status, attrs: attrs

            expect(find_trainee(attrs).pokerus).to eq expected_status
          end
        end

        ITEMS.each do |item|
          it "updates the #{item.titleize}" do
            within "#trainee_#{@id}" do
              find("span", text: item.titleize).click
              wait_for :item, item, attrs: attrs

              expect(find_trainee(attrs).item).to eq item
            end
          end
        end

        it "removes the item" do
          within "#trainee_#{@id}" do
            # In case there's no item, choose one and then go back
            find("span", text: ITEMS.first.titleize).click
            find("span", text: "None").click
            wait_for :item, nil, attrs: attrs

            expect(find_trainee(attrs).item).to be_nil
          end
        end
      end
    end

    TEST_KILL_BUTTONS.each do |id, data|
      context "when using the #{(name = data[:name])} kill button" do
        TEST_TRAINEES.each do |_, attrs|
          describe "the #{attrs[:nickname]} UI" do
            before :each do
              @trainee = find_trainee attrs

              # Calculate expected values based off Pokérus/held item
              data.delete :name
              @expected = calculate_final_evs attrs[:item], attrs[:pokerus],
                                              data, initial_evs: @trainee.evs

              # Click the kill button
              fill_in "Search", with: name
              find("##{id}").click
              # Use a stat that we know we're changing to wait for DB
              wait_stat = data.keys.first
              wait_for :"#{wait_stat}_ev", @expected[wait_stat], attrs: attrs
            end

            it "sets the EVs on the server" do
              @expected.each do |stat, value|
                expect((find_trainee attrs).send "#{stat}_ev").to eq value
              end
            end

            it "changes the values in the EV inputs" do
              within "#trainee_#{@trainee.id}" do
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

    TEST_TRAINEES.each do |_, attrs|
      describe "the close button for #{attrs[:nickname]}" do
        ["Bulbasaur", ""].each do |query|
          context "with#{query.blank? ? "out" : ""} a query" do
            before :each do
              if query.present?
                fill_in "Search", with: query
                sleep 0.5
              end

              @id = find_id attrs
              find("#close-trainee_#{@id}").click
            end

            it "removes the trainee from the page" do
              expect(page).not_to have_selector("#trainee_#{@id}")
            end

            it "doesn't delete the trainee from the server" do
              expect(find_trainee attrs).not_to be_nil
            end

            if query.present?
              it "retains the query string" do
                expect(current_url).to include query
              end
            end
          end
        end
      end

      describe "the delete button for #{attrs[:nickname]}" do
        ["Bulbasaur", ""].each do |query|
          context "with#{query.blank? ? "out" : ""} a query" do
            before :each do
              if query.present?
                fill_in "Search", with: query
                sleep 0.5
              end

              find("#delete-trainee_#{find_id attrs}").click
              sleep 0.5
              find("#confirm-delete").click
              sleep 0.5
            end

            it "deletes the trainee from the server" do
              expect(find_trainee attrs).to be_nil
            end

            it "doesn't delete the other trainees" do
              expect(Trainee.all.size).to eq TEST_TRAINEES.size - 1
            end

            if query.present?
              it "retains the query string" do
                expect(current_url).to include query
              end
            end
          end
        end
      end
    end

    describe "the new trainee button" do
      ["Bulbasaur", ""].each do |query|
        context "with#{query.blank? ? "out" : ""} a query" do
          before :each do
            if query.present?
              fill_in "Search", with: query
              sleep 0.5
            end

            @original_path = current_path
            find("#add-action-btn").click
            find("#new-trainee-btn").click
            sleep 0.5
          end

          it "adds a new trainee to the database" do
            expect(Trainee.all.size).to eq TEST_TRAINEES.size + 1
          end

          it "adds the new trainee to the end of the page" do
            expect(current_path).to include "#{@original_path},#{Trainee.last.id}"
          end

          if query.present?
            it "retains the query string" do
              expect(current_url).to include query
            end
          end
        end
      end
    end

    describe "the add to party menu" do
      ["Bulbasaur", ""].each do |query|
        context "with#{query.blank? ? "out" : ""} a query" do
          other_trainees = TEST_TRAINEES.to_a[1..-1].to_h

          before :each do
            # Start with 1 trainee
            visit trainee_path(Trainee.first)
            @original_path = current_path

            if query.present?
              fill_in "Search", with: query
              sleep 0.5
            end

            find("#add-action-btn").click
            find("#add-to-party-btn").click
          end

          other_trainees.each do |_, attrs|
            context "when you select #{attrs[:nickname]}" do
              before :each do
                @id = find_id attrs
                find("#check-trainee_#{@id}").hover_and_click
                find("#confirm-add-to-party").click
              end

              it "adds the trainee to the page" do
                expect(page).to have_selector("#trainee_#{@id}")
              end

              if query.present?
                it "retains the query string" do
                  expect(current_url).to include query
                end
              end
            end
          end

          context "when you select all trainees" do
            before :each do
              other_trainees.each do |_, attrs|
                find("#check-trainee_#{find_id attrs}").hover_and_click
              end
              find("#confirm-add-to-party").click
            end

            it "adds all of the trainees to the page" do
              TEST_TRAINEES.each do |_, attrs|
                expect(page).to have_selector("#trainee_#{find_id attrs}")
              end
            end

            if query.present?
              it "retains the query string" do
                expect(current_url).to include query
              end
            end
          end
        end
      end
    end
  end
end
