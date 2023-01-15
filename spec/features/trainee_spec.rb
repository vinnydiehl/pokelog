require "rails_helper"

TEST_TRAINEES = {
  "Bulbasaur" => {
    species_id: "001",
    nickname: "Bud",
    level: 50,
    nature: "bold",
    item: "power_bracer",
    hp_ev: 1,
    atk_ev: 2,
    def_ev: 3,
    spa_ev: 4,
    spd_ev: 5,
    spe_ev: 6
  },
  "Voltorb" => {
    species_id: "100",
    nickname: "Lefty",
    level: 75,
    nature: "naughty",
    item: "power_band",
    hp_ev: 6,
    atk_ev: 5,
    def_ev: 4,
    spa_ev: 3,
    spd_ev: 2,
    spe_ev: 1
  },
  "Voltorb (Hisuian)" => {
    species_id: "100-h",
    nickname: "Righty",
    level: 1,
    nature: "rash",
    item: "macho_brace",
    hp_ev: 4,
    atk_ev: 0,
    def_ev: 0,
    spa_ev: 252,
    spd_ev: 0,
    spe_ev: 252
  }
}
SINGLE_DISPLAY_NAME, SINGLE_ATTRS = TEST_TRAINEES.to_a.last

STATS = PokeLog::Stats.stats.map { |s| :"#{s}_ev" }

ITEMS = YAML.load_file("data/items.yml").keys

def click_away
  find("body").click
end

def wait_for(attr, value, **args)
  timeout = args[:timeout] || 5
  t = Time.now
  until Trainee.first.send(attr) == value
    break if Time.now - t > timeout
  end
end

def test_server_interaction
  describe "server interaction:", js: true do
    context "when changing the species" do
      before :each do
        fill_in "trainee_species", with: SINGLE_DISPLAY_NAME
        click_away
        wait_for :species, Species.find_by_display_name(SINGLE_DISPLAY_NAME.dup)
      end

      it "updates the species" do
        expect(Trainee.first.species_id).to eq SINGLE_ATTRS[:species_id]
      end

      it "updates the artwork" do
        expect(page).to have_xpath "//img[contains(@src,'artwork/#{SINGLE_ATTRS[:species_id]}.png')]"
      end
    end

    %w[nickname level].each do |field|
      it "updates the #{field}" do
        fill_in "trainee_#{field}", with: (value = SINGLE_ATTRS[field.to_sym])
        click_away
        wait_for field, value

        expect(Trainee.first.send field).to eq value
      end
    end

    it "updates the nature" do
      find("input.select-dropdown").click
      find("span", text: SINGLE_ATTRS[:nature].capitalize).click
      wait_for :nature, SINGLE_ATTRS[:nature]

      expect(Trainee.first.nature).to eq SINGLE_ATTRS[:nature]
    end

    STATS.each do |stat|
      it "updates #{stat}" do
        fill_in "trainee_#{stat}", with: SINGLE_ATTRS[stat]
        click_away
        wait_for stat, SINGLE_ATTRS[stat]

        expect(Trainee.first.send stat).to eq SINGLE_ATTRS[stat]
      end
    end

    describe "items:" do
      ITEMS.each do |item|
        it "updates the #{item.titleize}" do
          find("span", text: item.titleize).click
          wait_for :item, item

          expect(Trainee.first.item).to eq item
        end
      end

      it "removes the item" do
        # It starts on no item, so choose one and then go back
        # As long as the item update tests pass, this one is good
        find("span", text: ITEMS.first.titleize).click
        find("span", text: "No Item").click
        wait_for :item, nil

        expect(Trainee.first.item).to be_nil
      end
    end
  end
end

RSpec.feature "trainees:", type: :feature do
  describe "/trainees/:id", focus: true do
    before :each do
      create_user
    end

    context "with a blank trainee" do
      before :each do
        trainee = Trainee.new(user: User.first)
        trainee.save!
        visit trainee_path(trainee)
      end

      test_server_interaction

      it "displays the none artwork" do
        expect(page).to have_xpath "//img[contains(@src,'none.png')]"
      end

      describe "it prefills the fields:" do
        it "no item" do
          expect(page).to have_field "trainee_item", checked: true
        end

        %w[nickname species level nature].each do |field|
          it "blank #{field}" do
            expect(find_field("trainee_#{field}").value).to be_blank
          end
        end

        STATS.each do |stat|
          it "#{stat}: 0" do
            expect(page).to have_selector "#trainee_#{stat}[value='0']"
          end
        end
      end
    end

    context "with a populated trainee" do
      context "while logged in" do
        TEST_TRAINEES.each do |display_name, attrs|
          describe "test trainee: #{attrs[:nickname]}" do
            before :each do
              trainee = Trainee.new(user: User.first, **attrs)
              trainee.save!
              visit trainee_path(trainee)
            end

            # Don't run server tests for the species that's already loaded
            test_server_interaction if attrs[:species_id] != SINGLE_ATTRS[:species_id]

            it "displays the artwork" do
              expect(page).to have_xpath "//img[contains(@src,'artwork/#{attrs[:species_id]}.png')]"
            end

            describe "it prefills the fields:" do
              it "item: #{attrs[:item]}" do
                expect(page).to have_field "trainee_item_#{attrs[:item]}", checked: true
              end

              it "species: #{display_name}" do
                expect(page).to have_field "trainee_species", with: display_name
              end

              %w[nickname level nature].each do |field|
                expected_value = attrs[field.to_sym]
                it "#{field}: #{expected_value}" do
                  expect(page).to have_field "trainee_#{field}", with: expected_value
                end
              end

              STATS.each do |stat|
                expected_value = attrs[stat]
                it "#{stat}: #{expected_value}" do
                  expect(page).to have_selector "#trainee_#{stat}[value='#{expected_value}']"
                end
              end
            end
          end
        end
      end

      context "while logged out" do
        it "displays a static page" do
          display_name, attrs = TEST_TRAINEES.first
          trainee = Trainee.new(user: User.first, **attrs)
          trainee.save!
          visit trainee_path(trainee)

          # Make sure held item is selected
          expect(page).to have_field "trainee_item_#{attrs[:item]}", checked: true
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
            expected_value = attrs[stat]
            expect(find("#trainee_#{stat}[value='#{expected_value}']")[:disabled]).to eq "disabled"
          end
        end
      end
    end
  end
end
