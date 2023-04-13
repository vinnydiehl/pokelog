# frozen_string_literal: true

require "rails_helper"

TEST_PASTE = <<~EOS.strip
Test Mime (Mr. Mime-Galar) @ Assault Vest
Ability: Ice Body
Tera Type: Ice
EVs: 248 HP / 252 SpA / 8 Spe
Careful Nature
IVs: 0 Atk
- Dark Pulse
- Acid Spray
- Fairy Wind
- Earth Power

Azumarill
Ability: Thick Fat
Level: 75
Tera Type: Water
- Aqua Jet
- Encore
- Body Slam
- Grass Knot

Baxcalibur
Ability: Thermal Exchange
Tera Type: Dragon
EVs: 1 HP / 2 Atk / 3 Def / 4 SpA / 5 SpD / 6 Spe
IVs: 25 HP / 25 Atk / 25 Def / 25 SpA / 25 SpD / 25 Spe
- Blizzard
- Brick Break
EOS

TEST_PASTE_URL = "https://pokepast.es/e3cf76c6eca678f6"
TEST_PASTE_ID = "e3cf76c6eca678f6"

TEST_PASTE_ATTRS = {
  "122-g" => {
    nickname: "Test Mime",
    nature: "careful",
    level: 50,
    hp_ev: 0,
    atk_ev: 0,
    def_ev: 0,
    spa_ev: 0,
    spd_ev: 0,
    spe_ev: 0,
    hp_goal: 248,
    atk_goal: 0,
    def_goal: 0,
    spa_goal: 252,
    spd_goal: 0,
    spe_goal: 8
  },
  "184" => {
    nickname: nil,
    nature: "hardy",
    level: 75,
    hp_ev: 0,
    atk_ev: 0,
    def_ev: 0,
    spa_ev: 0,
    spd_ev: 0,
    spe_ev: 0,
    hp_goal: 0,
    atk_goal: 0,
    def_goal: 0,
    spa_goal: 0,
    spd_goal: 0,
    spe_goal: 0
  },
  "998" => {
    nickname: nil,
    nature: "hardy",
    level: 50,
    hp_ev: 0,
    atk_ev: 0,
    def_ev: 0,
    spa_ev: 0,
    spd_ev: 0,
    spe_ev: 0,
    hp_goal: 1,
    atk_goal: 2,
    def_goal: 3,
    spa_goal: 4,
    spd_goal: 5,
    spe_goal: 6
  }
}.freeze

RSpec.feature "PokéPaste support:", type: :feature, js: true do
  before do
    create_user
    log_in
    visit trainees_path
    find("#add-pokepaste-btn").click
    sleep 0.5
  end

  context "when entering a URL" do
    {URL: TEST_PASTE_URL, ID: TEST_PASTE_ID}.each do |name, data|
      context "if it is a valid PokéPaste #{name}" do
        before do
          find("#url").set data
          sleep 1
        end

        it "fills in the paste" do
          expect(find("#paste").value).to eq TEST_PASTE
        end

        it "enables the add button" do
          expect(page).to have_selector "#confirm-pokepaste:not(.disabled)"
        end

        if name == :URL
          context "and then you make it invalid" do
            before do
              find("#url").set "invalid data"
              sleep 1
            end

            it "doesn't change the paste field" do
              expect(find("#paste").value).to eq TEST_PASTE
            end
          end
        end
      end
    end

    context "if it is an invalid URL/ID" do
      before do
        find("#url").set "invalid"
        sleep 1
      end

      it "adds nothing to the paste field" do
        expect(find("#paste").value).to be_blank
      end

      it "keeps the add button disabled" do
        expect(page).to have_selector "#confirm-pokepaste.disabled"
      end
    end
  end

  context "when entering a valid paste" do
    before do
      find("#paste").set TEST_PASTE
    end

    it "enables the add button" do
      expect(page).to have_selector "#confirm-pokepaste:not(.disabled)"
    end

    context "when you click the add button" do
      before do
        find("#confirm-pokepaste").click
        sleep 0.5
      end

      it "creates the new trainees" do
        expect(Trainee.all.size).to eq TEST_PASTE_ATTRS.size
      end

      TEST_PASTE_ATTRS.each_with_index do |(species_id, attrs), index|
        describe "trainee index #{index}" do
          let(:trainee) { Trainee.all[index] }

          it "sets the species correctly" do
            expect(trainee.species.id).to eq species_id
          end

          attrs.each do |attr, value|
            it "sets :#{attr} correctly" do
              expect(trainee.send attr).to eq value
            end
          end
        end
      end

      it "takes you to the page for the new trainees" do
        expect(page).to have_current_path "/trainees/#{Trainee.all.map { |trn| trn.id }.join ','}"
      end
    end

    context "if you remove the paste" do
      before do
        find("#paste").set ""
      end

      it "disables the add button" do
        expect(page).to have_selector "#confirm-pokepaste.disabled"
      end
    end
  end
end
