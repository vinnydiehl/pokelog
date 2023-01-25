require "rails_helper"

require_relative "support/trainee_spec_helpers"

include TraineesHelper

RSpec.feature "trainees#show:", type: :feature do
  context "with multiple trainees in the party" do
    before :each do
      log_in
      TEST_TRAINEES.each do |_, attrs|
        trainee = Trainee.new user: User.first, **attrs
        trainee.save!
      end
      visit multi_trainees_path Trainee.all
    end

    TEST_TRAINEES.each do |display_name, attrs|
      test_trainee_ui display_name, attrs
    end

    TEST_TRAINEES.each do |_, attrs|
      context "if you clear all inputs for #{attrs[:nickname]}", js: true do
        before :each do
          @id = find_id attrs
        end

        STATS.each do |stat|
          it "sets #{stat} to 0 on the server" do
            within "#trainee_#{@id}" do
              fill_in "trainee_#{stat}", with: "0"
              wait_for stat, 0, attrs: attrs

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
            find("span", text: "No Item").click
            wait_for :item, nil, attrs: attrs

            expect(find_trainee(attrs).item).to be_nil
          end
        end
      end
    end

    TEST_KILL_BUTTONS.each do |id, data|
      context "when using the #{data[:name]} kill button", js: true do
        TEST_TRAINEES.each do |_, attrs|
          describe "the #{attrs[:nickname]} UI" do
            before :each do
              @trainee = find_trainee attrs

              # Calculate expected values based off Pokérus/held item
              data.delete :name
              @expected = calculate_final_evs attrs[:item], attrs[:pokerus],
                                              data, @trainee.evs

              # Click the kill button
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
        before :each do
          @id = find_id attrs
          find("#close-trainee_#{@id}").click
        end

        it "removes the trainee from the page" do
          expect(page).not_to have_selector("#trainee_#{@id}")
        end

        it "doesn't delete the trainee from the server" do
          expect(find_trainee attrs).not_to be_nil
        end
      end

      describe "the delete button for #{attrs[:nickname]}", js: true do
        before :each do
          find("#delete-trainee_#{find_id attrs}").click
          find("#confirm-delete").click
        end

        it "deletes the trainee from the server" do
          expect(find_trainee attrs).to be_nil
        end

        it "doesn't delete the other trainees" do
          expect(Trainee.all.size).to eq TEST_TRAINEES.size - 1
        end
      end
    end

    describe "the new trainee button", js: true do
      before :each do
        @original_path = current_path
        find("#add-action-btn").hover
        find("#new-trainee-btn").click
      end

      it "adds a new trainee to the database" do
        sleep 0.5
        expect(Trainee.all.size).to eq TEST_TRAINEES.size + 1
      end

      it "adds the new trainee to the end of the page" do
        sleep 0.5
        expect(current_path).to eq "#{@original_path},#{Trainee.last.id}"
      end
    end

    describe "the add to party menu", js: true do
      other_trainees = TEST_TRAINEES.to_a[1..-1].to_h

      before :each do
        # Start with 1 trainee
        visit trainee_path(Trainee.first)
        @original_path = current_path

        find("#add-action-btn").hover
        find("#add-to-party-btn").click
      end

      other_trainees.each do |_, attrs|
        context "when you select #{attrs[:nickname]}" do
          it "adds the trainee to the page" do
            id = find_id attrs
            find("#check-trainee_#{id}").click
            find("#confirm-add-to-party").click

            expect(page).to have_selector("#trainee_#{id}")
          end
        end
      end

      context "when you select all trainees" do
        it "adds all of the trainees to the page" do
          other_trainees.each do |_, attrs|
            find("#check-trainee_#{find_id attrs}").click
          end
          find("#confirm-add-to-party").click

          TEST_TRAINEES.each do |_, attrs|
            expect(page).to have_selector("#trainee_#{find_id attrs}")
          end
        end
      end
    end
  end
end
