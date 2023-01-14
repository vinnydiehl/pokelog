require "rails_helper"

RSpec.feature "trainees:", type: :feature do
  describe "/trainees/:id" do
    before :each do
      create_user
    end

    context "with a blank trainee" do
      before :each do
        trainee = Trainee.new(user: User.first)
        trainee.save!
        visit trainee_path(trainee)
      end

      it "displays the none artwork" do
        expect(page).to have_xpath "//img[contains(@src,'none.png')]"
      end

      describe "it prefills the fields:" do
        it "no item" do
          expect(page).to have_field "trainee_item", checked: true
        end

        %w[nickname species level nature].each do |field|
          it "blank #{field}" do
            expect(find_field("trainee_#{field}").value).to be_blank
          end
        end

        %w[hp atk def spa spd spe].each do |stat|
          it "0 #{stat}" do
            expect(page).to have_selector "#trainee_#{stat}_ev[value='0']"
          end
        end
      end
    end

    context "with a populated trainee" do
      test_trainees = {
        "Bulbasaur" => {
          species_id: "001",
          nickname: "Bud",
          level: 50,
          nature: "bold",
          item: "power_bracer",
          hp_ev: 1,
          atk_ev: 2,
          def_ev: 3,
          spa_ev: 4,
          spd_ev: 5,
          spe_ev: 6
        },
        "Voltorb" => {
          species_id: "100",
          nickname: "Lefty",
          level: 75,
          nature: "naughty",
          item: "power_band",
          hp_ev: 6,
          atk_ev: 5,
          def_ev: 4,
          spa_ev: 3,
          spd_ev: 2,
          spe_ev: 1
        },
        "Voltorb (Hisuian)" => {
          species_id: "100-h",
          nickname: "Righty",
          level: 1,
          nature: "rash",
          item: "macho_brace",
          hp_ev: 4,
          atk_ev: 0,
          def_ev: 0,
          spa_ev: 252,
          spd_ev: 0,
          spe_ev: 252
        }
      }

      context "while logged in" do
        test_trainees.each do |display_name, attrs|
          describe "test trainee: #{attrs[:nickname]}" do
            before :each do
              trainee = Trainee.new(user: User.first, **attrs)
              trainee.save!
              visit trainee_path(trainee)
            end
            it "displays the artwork" do
              expect(page).to have_xpath "//img[contains(@src,'artwork/#{attrs[:species_id]}.png')]"
            end

            describe "it prefills the fields:" do
              it "item: #{attrs[:item]}" do
                expect(page).to have_field "trainee_item_#{attrs[:item]}", checked: true
              end

              it "species: #{display_name}" do
                expect(page).to have_field "trainee_species", with: display_name
              end

              %w[nickname level nature].each do |field|
                expected_value = attrs[field.to_sym]
                it "#{field}: #{expected_value}" do
                  expect(page).to have_field "trainee_#{field}", with: expected_value
                end
              end

              %w[hp atk def spa spd spe].each do |stat|
                expected_value = attrs["#{stat}_ev".to_sym]
                it "#{stat}: #{expected_value}" do
                  expect(page).to have_selector "#trainee_#{stat}_ev[value='#{expected_value}']"
                end
              end
            end
          end
        end
      end

      context "while logged out" do
        it "doesn't allow you to edit the trainee" do
        end
      end
    end
  end
end
