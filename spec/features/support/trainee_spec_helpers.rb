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
    hp_ev: 10,
    atk_ev: 0,
    def_ev: 0,
    spa_ev: 150,
    spd_ev: 0,
    spe_ev: 150
  }
}
SINGLE_DISPLAY_NAME, SINGLE_ATTRS = TEST_TRAINEES.to_a.last

# For tests which require a blank trainee and nothing more. To be run at the
# beginning of the feature, this creates a user and everything.
def launch_new_blank_trainee
  create_user
  log_in

  trainee = Trainee.new(user: User.first)
  trainee.save!

  visit trainee_path trainee
end

def launch_multi_trainee
  create_user
  log_in

  TEST_TRAINEES.each do |_, attrs|
    trainee = Trainee.new user: User.first, **attrs
    trainee.save!
  end

  visit multi_trainees_path Trainee.all
end

# Set a trainee's EV to a certain value. Works with or without _ev suffix.
def set_ev(stat, value, **args)
  fill_in "trainee_#{stat = stat.to_s.sub(/_ev/, "")}_ev", with: value
  wait_for :"#{stat}_ev", value, attrs: args[:attrs]
end

# Find a trainee by the value (Hash) of the test cases above
def find_trainee(attrs)
  # Falls back on species, this could break if more test cases are added with
  # redundant species
  Trainee.find_by_nickname(attrs[:nickname]) ||
    Trainee.find_by(species_id: attrs[:species_id])
end

# Find a trainee ID by the value (Hash) of the test cases above
def find_id(attrs)
  find_trainee(attrs).id
end

STATS = PokeLog::Stats.stats.map { |s| :"#{s}_ev" }
GOALS = PokeLog::Stats.stats.map { |s| :"#{s}_goal" }

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

def click_away(**args)
  if args[:within] == :trainee_info
    find(".ev-info").click
  else
    find("body").click
  end
end

# Wait for server to update e.g. after updating a single-page form
# Checks Trainee.first unless you send the TEST_TRAINEES item attrs in.
def wait_for(attr, value, **args)
  timeout = args[:timeout] || 5
  t = Time.now
  until (args[:attrs] ? find_trainee(args[:attrs]) : Trainee.first).send(attr) == value
    break if Time.now - t > timeout
  end
end

def test_trainee_ui(display_name, attrs)
  describe "the trainee UI for #{display_name}", js: false do
    it "displays the artwork for #{attrs[:nickname] || 'no trainee'}" do
      within "#trainee_#{find_id attrs}" do
        expect(page).to have_xpath "//img[contains(@src,'artwork/#{attrs[:species_id] || 'none'}.png')]"
      end
    end

    describe "has pre-filled fields:" do
      it "item: #{attrs[:item] || 'none'}" do
        within "#trainee_#{find_id attrs}" do
          id_suffix = attrs[:item] ? "_#{attrs[:item]}" : nil
          expect(page).to have_field "trainee_item#{id_suffix}", checked: true
        end
      end

      it "species: #{display_name || 'none'}" do
        within "#trainee_#{find_id attrs}" do
          expect(find_field("trainee_species").value).to eq display_name
        end
      end

      %w[nickname level nature].each do |field|
        expected_value = attrs[field.to_sym] ? attrs[field.to_sym].to_s : nil
        it "#{field}: #{expected_value || 'none'}" do
          within "#trainee_#{find_id attrs}" do
            expect(find_field("trainee_#{field}").value).to eq expected_value
          end
        end
      end

      STATS.each do |stat|
        expected_value = attrs[stat].zero? ? nil : attrs[stat].to_s
        it "#{stat}: #{expected_value || 'blank'}" do
          within "#trainee_#{find_id attrs}" do
            expect(find_field("trainee_#{stat}").value).to eq expected_value
          end
        end
      end
    end
  end
end

def test_max_evs_per_stat(max)
  context "with #{max - 1} HP EVs", js: true do
    before :each do
      set_ev :hp, max - 1
    end

    describe "a 2 HP kill button" do
      before :each do
        fill_in "Search", with: "Jigglypuff"
        find("#species_039").click
        wait_for :hp_ev, max
      end

      it "increments the HP EV to #{max}" do
        expect(find("#trainee_hp_ev").value).to eq max.to_s
        expect(Trainee.first.hp_ev).to eq max
      end
    end
  end
end

module PokeLog
  class Stats
    def double_values
      PokeLog::Stats.new(
        map { |stat, value| { stat.to_sym => value * 2 } }.inject(:merge)
      )
    end
  end
end

def calculate_final_evs(item, pokerus, kill_button_data, **args)
  args[:power_boost] ||= 8

  # Set stats to the base yield from the kill button
  expected = PokeLog::Stats.new
  kill_button_data.each { |stat, value| expected[stat] = value }

  case item
  when "macho_brace"
    expected = expected.double_values
  when "power_weight"
    expected[:hp] += args[:power_boost]
  when "power_bracer"
    expected[:atk] += args[:power_boost]
  when "power_belt"
    expected[:def] += args[:power_boost]
  when "power_lens"
    expected[:spa] += args[:power_boost]
  when "power_band"
    expected[:spd] += args[:power_boost]
  when "power_anklet"
    expected[:spe] += args[:power_boost]
  end

  if pokerus
    expected = expected.double_values
  end

  expected + args[:initial_evs]
end

def test_server_interaction
  describe "server interaction:", js: true do
    context "when changing the species" do
      before :each do
        fill_in "trainee_species", with: SINGLE_DISPLAY_NAME
        click_away
        wait_for :species, Species.find_by_display_name(SINGLE_DISPLAY_NAME)
        # The server updates before the page, sleep just to be safe
        sleep 0.2
      end

      it "updates the species" do
        expect(Trainee.first.species_id).to eq SINGLE_ATTRS[:species_id]
      end

      it "changes the artwork" do
        expect(page).to have_xpath "//img[contains(@src,'artwork/#{SINGLE_ATTRS[:species_id]}.png')]"
      end

      it "changes the types" do
        Species.find(SINGLE_ATTRS[:species_id]).types.each do |type|
          expect(find ".sprite-and-types").to have_css ".#{type}"
        end
      end
    end

    context "when changing the nickname" do
      value = SINGLE_ATTRS[:nickname]

      before :each do
        fill_in "trainee_nickname", with: value
        click_away
        wait_for :nickname, value
        # The server updates before the page, sleep just to be safe
        sleep 0.2
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
        find("span", text: "None").click
        wait_for :item, nil

        expect(Trainee.first.item).to be_nil
      end
    end

    context "when changing stats manually" do
      STATS.each do |stat|
        it "updates #{stat}" do
          set_ev stat, SINGLE_ATTRS[stat]

          expect(Trainee.first.send stat).to eq SINGLE_ATTRS[stat]
        end
      end
    end

    describe "the delete button modal" do
      before :each do
        find(".delete-btn").click
        sleep 0.5
      end

      context "when accepted" do
        before :each do
          find("#confirm-delete").click
          sleep 0.5
        end

        it "redirects to trainees#index" do
          expect(page).to have_current_path trainees_path
        end

        it "displays a notice" do
          expect(page).to have_selector "#notice"
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
