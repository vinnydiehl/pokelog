# frozen_string_literal: true

require "rails_helper"

RSpec.feature "generations:", type: :feature, js: true do
  context "with one trainee" do
    before do
      launch_new_blank_trainee
    end

    # Wings/Feathers Name
    [[(3..7), "Wings"   ],
     [(8..9), "Feathers"]].each do |range, name|
      range.each do |gen|
        context "generation #{gen}:" do
          before do
            set_generation gen
            open_consumables_menu
          end

          it "they are called #{name.downcase}" do
            expect(page).to have_selector ".items-menu h5", text: name
          end
        end
      end
    end

    # Disabled?
    [[(3..4), false],
     [(5..9), true ]].each do |range, availability|
      range.each do |gen|
        context "generation #{gen}:" do
          before do
            set_generation gen
            open_consumables_menu
          end

          it "feathers are#{availability ? '' : ' not'} available" do
            expect(page).to have_selector(
              ".consumables-buttons .btn#{availability ? '' : '.disabled'}"
            )
          end
        end
      end
    end
  end
end
