# frozen_string_literal: true

require "rails_helper"

RSpec.feature "generations:", type: :feature, js: true do
  context "with one trainee" do
    [[(3..7), [[  0, 10 ],
               [ 95, 100],
               [101, 101]]],
     [(8..9), [[ 95, 105],
               [250, 252]]]].each do |range, test_cases|
      range.each do |gen|
        context "generation #{gen}:" do
          before do
            launch_new_blank_trainee
            set_generation gen
            open_consumables_menu
          end

          test_consumables vitamins: test_cases
        end
      end
    end
  end
end
