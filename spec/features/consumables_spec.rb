require "rails_helper"

require_relative "support/trainee_spec_helpers"

include StatsHelper

RSpec.feature "consumables:", type: :feature, js: true do
  context "with a blank trainee" do
    before :each do
      launch_new_blank_trainee
      find(".collapsible-header .expand").click
      sleep 0.5
    end

    # Test cases are [start_value, expected_result]
    {
      vitamins: [[  0, 10 ],
                 [ 90, 100],
                 [ 99, 100],
                 [101, 101]],
      feathers: [[  0, 1  ],
                 [150, 151],
                 [254, 255],
                 [255, 255]],
      berries:  [[255, 245],
                 [100, 90 ],
                 [  5, 0  ]]
    }.each do |item_type, test_cases|
      describe "#{item_type}:" do
        STATS.each do |stat|
          item = PokeLog::Stats.consumables_for(stat)[item_type.to_s.singularize.to_sym]

          describe "#{item.to_s.humanize.downcase}" do
            test_cases.each do |start_value, expected_value|
              context "with #{start_value} #{format_stat stat}" do
                difference = expected_value - start_value
                action = difference < 0 ? "subtracts" : "adds"

                it "#{action} #{difference.abs} #{format_stat stat} EVs" do
                  set_ev stat, start_value unless start_value.zero?
                  find(".#{item_type} .#{item}").click
                  wait_for stat, expected_value

                  expect(Trainee.first.send stat).to eq expected_value
                end
              end
             end
          end
        end
      end
    end

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

  context "with multiple trainees in the party", focus: true do
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
