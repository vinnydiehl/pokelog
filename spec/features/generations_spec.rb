# With no generation selected, Pokémon from all generations are shown in the
# search results, and the behavior of everything else is set to the most recent
# generation by default. This core behavior tested throughout the rest of the
# test suite. This file is only for cases where the generation has been changed.

require "rails_helper"

def set_generation(gen)
  ###
end

def test_power_item_boost(item, expected_boost)
  ###
end

RSpec.feature "generations:", type: :feature, js: true do
  before :each do
    launch_new_blank_trainee
  end

  context "generation 3:" do
    it "the power items are disabled" do
    end
  end

  context "generation 7:" do
    it "the macho brace is disabled" do
    end
  end

  context "generation 4:" do
    # test_consumables({
    #   berries:
    # })
  end

  # Individual stat caps
  [[(3..5), 255],
    (6..9), 252]].each do |range, max_evs|
    range.each do |gen|
      context "generation #{gen}:" do
        before :each { set_generation gen }

        test_max_evs_per_stat max_evs
      end
    end
  end

  # Power items
  [[(4..6), 4],
    (7..9), 8]].each do |range, boost|
    range.each do |gen|
      context "generation #{gen}:" do
        before :each { set_generation gen }

        ITEMS.each { |item| test_power_item_boost item, boost }
      end
    end
  end

  # Vitamins
  [[(3..6), []],
    (7..9), []]].each do |range, test_cases|
    range.each do |gen|
      context "generation #{gen}:" do
        before :each { set_generation gen }

        test_consumables({vitamins: test_cases})
      end
    end
  end
end
