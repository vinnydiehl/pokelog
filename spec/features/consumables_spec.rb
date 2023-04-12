# frozen_string_literal: true

require "rails_helper"

RSpec.feature "consumables:", type: :feature, js: true do
  context "with a blank trainee" do
    before :each do
      launch_new_blank_trainee
      open_consumables_menu
    end

    test_consumables vitamins: [[  0, 10 ],
                                [ 99, 109],
                                [101, 111],
                                [248, 252]],
                     feathers: [[  0, 1  ],
                                [150, 151],
                                [251, 252],
                                [252, 252]],
                      berries: [[252, 242],
                                [100, 90 ],
                                [  5, 0  ]]

    context "with 509 total EVs" do
      describe "a vitamin button" do
        it "adds 1 EV" do
          # Set everything except HP to 100
          STATS[1..-1].each do |stat|
            fill_in "trainee_#{stat}", with: 100
          end
          wait_for STATS.last, 100
          # And HP to 9
          set_ev STATS.first, (original = 9)
          find(".vitamins .hp_up").click
          wait_for :hp_ev, (expected_value = original + 1)

          expect(Trainee.first.hp_ev).to eq expected_value
        end
      end
    end
  end

  context "with multiple trainees in the party" do
    describe "the consumables buttons" do
      before :each do
        launch_multi_trainee

        attrs = TEST_TRAINEES.first.last
        @expected_value = attrs[:hp_ev] + 10

        fail "HP EV needs to be <= 90 for the test." if @expected_value > 100

        within "#trainee_#{Trainee.first.id}" do
          [".expand", ".hp_up"].each { |klass| find(klass).click }
          wait_for :hp_ev, @expected_value, attrs: attrs
        end
      end

      it "affect the chosen trainee" do
        expect(Trainee.first.hp_ev).to eq @expected_value
      end

      it "do not effect the other trainees" do
        Trainee.all.select { |trn| trn != Trainee.first }.each do |trainee|
          expect(trainee.hp_ev).to eq TEST_TRAINEES[trainee.species.display_name][:hp_ev]
        end
      end
    end
  end
end
