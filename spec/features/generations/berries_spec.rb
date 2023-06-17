# frozen_string_literal: true

require "rails_helper"

RSpec.feature "generations:", type: :feature, js: true do
  context "with one trainee" do
    [[             [4], [[252, 100],
                         [109, 99 ],
                         [ 99, 89 ],
                         [  5, 0  ]]],
     [(3..9).except(4), [[252, 242],
                         [100, 90 ],
                         [  5, 0  ]]]].each do |range, test_cases|
      range.each do |gen|
        context "generation #{gen}:" do
          before do
            launch_new_blank_trainee
            set_generation gen
            open_consumables_menu
          end

          test_consumables berries: test_cases
        end
      end
    end
  end
end
