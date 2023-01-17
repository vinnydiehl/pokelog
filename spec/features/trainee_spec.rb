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

# Test cases for kill buttons. These selections cover a good range of cases;
# each stat is tested, some affect multiple stats, increase stats by different
# amounts, etc.
# {
#   species_003: {name: "Venusaur", spa: 2, spd: 1},
#   species_004: {name: "Charmander", spe: 1},
#   ...
# }
TEST_KILL_BUTTONS = %w[003 004 011 034 590 797].map do |id|
  { "species_#{id}": {name: (s = Species.find(id)).name}.merge(s.yields) }
end.inject(:merge)

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

class Hash
  def double_values
    map { |stat, value| { stat.to_sym => value * 2 } }.inject(:merge)
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

      it "changes the artwork" do
        expect(page).to have_xpath "//img[contains(@src,'artwork/#{SINGLE_ATTRS[:species_id]}.png')]"
      end
    end

    context "when changing the nickname" do
      value = SINGLE_ATTRS[:nickname]

      before :each do
        fill_in "trainee_nickname", with: value
        click_away
        wait_for :nickname, value
      end

      it "updates the nickname" do
        expect(Trainee.first.nickname).to eq value
      end

      it "changes the page title" do
        expect(find("#title").text).to eq Trainee.first.title
      end
    end

    it "updates the level" do
      fill_in "trainee_level", with: (value = SINGLE_ATTRS[:level])
      click_away
      wait_for :level, value

      expect(Trainee.first.level).to eq value
    end

    it "updates the nature" do
      find("input.select-dropdown").click
      find("span", text: SINGLE_ATTRS[:nature].capitalize).click
      wait_for :nature, SINGLE_ATTRS[:nature]

      expect(Trainee.first.nature).to eq SINGLE_ATTRS[:nature]
    end

    it "updates Pokérus status" do
      expected_status = !Trainee.first.pokerus
      find(".pokerus label").click
      wait_for :pokerus, expected_status

      expect(Trainee.first.pokerus).to eq expected_status
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

    context "when changing stats manually" do
      STATS.each do |stat|
        it "updates #{stat}" do
          fill_in "trainee_#{stat}", with: SINGLE_ATTRS[stat]
          click_away
          wait_for stat, SINGLE_ATTRS[stat]

          expect(Trainee.first.send stat).to eq SINGLE_ATTRS[stat]
        end
      end
    end

    describe "the delete button modal" do
      before :each do
        find("#delete").click
      end

      context "when accepted" do
        before :each do
          find("#confirm-delete").click
        end

        it "redirects to trainees#index" do
          expect(page).to have_current_path trainees_path
        end

        it "deletes the trainee" do
          expect(Trainee.all.size).to eq 0
        end
      end

      context "when declined" do
        before :each do
          find("#cancel-delete").click
        end

        it "stays on the trainee page" do
          expect(page).to have_current_path trainee_path(Trainee.first)
        end

        it "doesn't delete the trainee" do
          expect(Trainee.all.size).to eq 1
        end
      end
    end
  end
end

RSpec.feature "trainees:", type: :feature do
  describe "/trainees/:id" do
    before :each do
      create_user
    end

    context "with a blank trainee" do
      before :each do
        log_in
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
            expect(page).to have_field "trainee_#{stat}", with: 0
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
                    @expected = PokeLog::Stats.new
                    data.delete :name
                    data.each { |stat, value| @expected[stat] = value }
                    case item
                    when "macho_brace"
                      @expected = @expected.double_values
                    when "power_weight"
                      @expected[:hp] += 4
                    when "power_bracer"
                      @expected[:atk] += 4
                    when "power_belt"
                      @expected[:def] += 4
                    when "power_lens"
                      @expected[:spa] += 4
                    when "power_band"
                      @expected[:spd] += 4
                    when "power_anklet"
                      @expected[:spe] += 4
                    end
                    if pokerus
                      @expected = @expected.double_values
                    end

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
                      expect(page).to have_field "trainee_#{stat}_ev", with: value
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
              log_in
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
                  expect(page).to have_field "trainee_#{stat}", with: expected_value
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
            expected_value = attrs[stat]
            expect(find("#trainee_#{stat}[value='#{expected_value}']")[:disabled]).to eq "disabled"
          end
        end

        it "does not display the kill search" do
          expect(page).not_to have_selector("#kill-search")
        end

        it "does not display the delete button" do
          expect(page).not_to have_selector("#delete")
        end
      end
    end
  end
end
