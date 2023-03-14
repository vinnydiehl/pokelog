def set_generation(gen)
  find("#filters-btn").click
  find("#species-filters .select-wrapper").click
  find("span", text: gen.to_s).hover_and_click
  sleep 0.5
end

def set_held_item(item)
  find("span", text: item.to_s.titleize).click
  wait_for :item, item
end

def stat_for(item)
  {
    power_weight: :hp_ev,
    power_bracer: :atk_ev,
    power_belt: :def_ev,
    power_lens: :spa_ev,
    power_band: :spd_ev,
    power_anklet: :spe_ev
  }[item.to_sym]
end

def test_power_item_boost(item, expected_boost)
  context "when you click a 1 HP kill button holding a #{item.titleize}" do
    it "increases #{stat = stat_for(item)} by #{expected_boost}" do
      set_held_item item
      fill_in "Search", with: "Slowpoke" # 1 HP, available in all gens
      find("#species_079").click
      wait_for :hp_ev, (1 + (stat == :hp_ev ? expected_boost : 0))

      expect(Trainee.first.send stat).to eq(expected_boost + (stat == :hp_ev ? 1 : 0))
    end
  end
end

def check_with_refresh(&block)
  block.call
  refresh
  block.call
end

# (3..9).except(4) #=> [3, 5, 6, 7, 8, 9]
class Range
  def except(value)
    self.to_a.reject { |n| n == value }
  end
end
