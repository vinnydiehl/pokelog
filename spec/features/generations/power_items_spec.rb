# frozen_string_literal: true

require "rails_helper"

RSpec.feature "generations:", type: :feature, js: true do
  context "with one trainee" do
    [[(4..6), 4],
     [(7..9), 8]].each do |range, boost|
      range.each do |gen|
        context "generation #{gen}:" do
          before do
            launch_new_blank_trainee
            set_generation gen
            open_consumables_menu
          end

          POWER_ITEMS.each { |item| test_power_item_boost item, boost }
        end
      end
    end
  end
end
