require "rails_helper"

require_relative "support/trainee_spec_helpers"

TEST_CHANGED_EMAIL = "t2@test.com"

RSpec.feature "users:", type: :feature do
  describe "the profile link in the sidenav" do
    it "links to the user's profile" do
      find("#profile-widget").click
      find("#profile-link").click

      expect(page).to have_current_path user_path(User.first)
    end
  end

  describe "/users/:username" do
    before :each do
      TEST_TRAINEES.each do |_, attrs|
        trainee = Trainee.new user: User.first, **attrs
        trainee.save!
      end
    end

    context "if the user does not exist" do
      it "404s" do
        visit "/users/nobodyhome"

        expect(page).to have_current_path "/404"
      end
    end

    context "if the user exists" do
      context "while logged out" do
        before :each do
          visit "/users/#{TEST_USERNAME}"
        end

        it "disables the email input" do
          expect(page).to have_field "email", disabled: true
        end

        it "does not have a change button" do
          expect(page).not_to have_button "Change"
        end

        ### General tests regarding the page. These also apply while logged in.

        it "displays artwork linking to the user's trainees" do
          User.first.trainees.each do |trainee|
            if trainee.species
              expect(page).to have_xpath("//a[contains(@href,'#{trainee_path trainee}')]//img[contains(@src,'artwork/#{trainee.species.id}.png')]")
            end
          end
        end

        it "doesn't display none artwork" do
          expect(page).not_to have_xpath "//img[contains(@src,'artwork/none.png')]"
        end
      end

      context "while logged in" do
        before :each do
          log_in
          visit user_path User.first
        end

        describe "the change button" do
          it "is disabled" do
            expect(page).to have_button "Change", disabled: true
          end

          context "when the email is changed" do
            # Running this before the invalid change- that way it changes
            # to a valid input, and then back.
            before :each do
              fill_in "email", with: TEST_CHANGED_EMAIL
            end

            context "to a valid input and pressed" do
              before :each do
                click_button "Change"
              end

              it "remains on the profile page" do
                expect(page).to have_current_path user_path(User.first)
              end

              it "changes the user's email" do
                expect(User.first.email).to eq TEST_CHANGED_EMAIL
              end
            end

            context "to an invalid input" do
              it "is disabled" do
                expect(page).to have_button "Change", disabled: true
              end
            end
          end
        end
      end
    end
  end
end
