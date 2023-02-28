# With no goal set in any given input, it will have no effect. This behavior is
# tested throughout the rest of the suite; this file pertains only to behaviors
# that happen when goals are set.

require "rails_helper"

def modal_should_display
  it "displays an alert" do
    expect(page).to have_selector "#goal-alert", visible: true
  end
end

def modal_should_not_display
  it "does not display an alert" do
    expect(page).to have_selector "#goal-alert", visible: false
  end
end

RSpec.feature "EV goals:", type: :feature, js: true do
  before :each do
    launch_new_blank_trainee
  end

  context "when a goal is set:" do
    [[nil,           nil, 3],
     [:macho_brace,  nil, 6],
     [:power_belt,   nil, 11],
     [:power_belt,   6,   7],
     [:power_bracer, nil, 3]].each do |item, generation, offset|
      context "generation: #{generation || 'none'} |" do
        before :each do
          set_generation(generation) if generation
        end

        context "item: #{item || 'none'} |" do
          before :each do
            find("span", text: item.to_s.titleize).click if item
          end

          [true, false].each do |pokerus|
            context "pokerus: #{pokerus} |" do
              before :each do
                @offset = offset

                if pokerus
                  find(".pokerus label").click
                  @offset *= 2
                end

                set_goal :def, (@goal = 150)
              end

              context "when the EV is #{offset + 1} away" do
                before :each do
                  set_ev :def, @goal - @offset - 1
                end

                modal_should_not_display
              end

              context "when the EV is #{offset} away" do
                before :each do
                  set_ev :def, @goal - @offset
                end

                modal_should_display
              end

              context "when you use a kill button to enter alert range" do
                before :each do
                  set_ev :def, @goal - @offset - 1
                  fill_in "Search", with: "Squirtle" # 1 Def
                  find("#species_007").click
                end

                modal_should_display
              end
            end
          end
        end
      end
    end

    context "and a different EV approaches/passes it" do
      before :each do
        set_goal :spa, 50
        set_ev :atk, 49
        set_ev :atk, 51
      end

      modal_should_not_display
    end
  end

  context "when an item change will cause an overshoot" do
    before :each do
      set_goal :spe, 10
      find("span", text: "Power Anklet").click
    end

    modal_should_display
  end

  context "when an item change will not cause an overshoot" do
    before :each do
      set_goal :spe, 11
      find("span", text: "Power Anklet").click
    end

    modal_should_not_display
  end

  context "when an item change is irrelevant" do
    before :each do
      set_goal :spe, 10
      find("span", text: "Power Band").click
    end

    modal_should_not_display
  end

  context "when the goal is exceeded" do
    before :each do
      set_goal :spd, 50
      set_ev :spd, 51
    end

    modal_should_display
  end
end
