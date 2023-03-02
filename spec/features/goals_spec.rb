# With no goal set in any given input, it will have no effect. This behavior is
# tested throughout the rest of the suite; this file pertains only to behaviors
# that happen when goals are set.

require "rails_helper"

def modal_should_display
  it "displays an alert" do
    sleep 0.5
    expect(page).to have_selector "#goal-alert", visible: true
  end
end

def modal_should_not_display
  it "does not display an alert" do
    sleep 0.5
    expect(page).not_to have_selector "#goal-alert", visible: true
  end
end

def text_color_of(element)
  element.style("color").values.first
end

RSpec.feature "EV goals:", type: :feature, js: true do
  context "with a single trainee" do
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

    %w[.ev-input .goal-input].each do |klass|
      it "changes color of the #{klass.titleize.downcase[1..-1]} with each stage" do
        input = find(".hp #{klass}")

        # Find initial color, as they change they will be loaded into this array. We can check
        # against the array to see if it has changed to a new color, and at the end we will
        # make sure it turns back to this first one:
        colors = [text_color_of(input)]

        set_goal :hp, 50

        # Check yellow, green, and red respectively (not the specific colors, just that
        # they change and are unique)
        [47, 50, 51].each do |evs|
          set_ev :hp, evs
          click_away
          find("#close-goal-alert").click

          new_color = text_color_of input
          expect(colors).not_to include new_color
          colors << new_color
        end

        # Make sure it turns back to black
        set_goal :hp, 0
        click_away
        expect(text_color_of input).to eq colors.first
      end
    end
  end

  context "with multiple trainees" do
    trainee_name, trainee_attrs = TEST_TRAINEES.first
    other_name, other_attrs = TEST_TRAINEES.to_a.last

    before :each do
      launch_multi_trainee
    end

    context "when #{trainee_name} is put within alert range via the EV input" do
      before :each do
        set_goal :atk, 50, attrs: trainee_attrs
        set_ev :atk, 47, attrs: trainee_attrs
        click_away
      end

      modal_should_display

      context "and then" do
        before :each do
          find("#close-goal-alert").click
        end

        context "you focus then un-focus that stat without changing it" do
          before :each do
            set_ev :atk, 47, attrs: trainee_attrs
            click_away
          end

          modal_should_not_display
        end

        context "you edit a different stat with no alert set" do
          before :each do
            set_ev :hp, 47, attrs: trainee_attrs
            click_away
          end

          modal_should_not_display
        end

        context "you edit an input of #{other_name} with no goal set" do
          before :each do
            set_ev :atk, 47, attrs: other_attrs
            click_away
          end

          modal_should_not_display
        end

        context "you edit a different stat and put that into alert range" do
          before :each do
            set_goal :spe, 50, attrs: trainee_attrs
            set_ev :spe, 47, attrs: trainee_attrs
            click_away
          end

          modal_should_display

          # We now have 2 alerts sent, from Atk and Spe from trainee 1
          context "and then" do
            before :each do
              find("#close-goal-alert").click
            end

            context "you change a previously alerted EV to trigger another alert" do
              before :each do
                set_ev :atk, 47, attrs: trainee_attrs
                click_away
              end

              modal_should_display
            end

            context "you edit an input of #{other_name} to put it within alert range" do
              before :each do
                set_goal :hp, 50, attrs: other_attrs
                set_ev :hp, 47, attrs: other_attrs
                click_away
              end

              modal_should_display
            end

            context "you edit a different stat with no alert set" do
              before :each do
                set_ev :spd, 47, attrs: trainee_attrs
                click_away
              end

              modal_should_not_display
            end

            context "you edit an input of #{other_name} with no goal set" do
              before :each do
                set_ev :spd, 47, attrs: other_attrs
                click_away
              end

              modal_should_not_display
            end
          end
        end
      end
    end
  end
end
