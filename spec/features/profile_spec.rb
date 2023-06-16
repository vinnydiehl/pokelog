# frozen_string_literal: true

require "rails_helper"

TEST_CHANGED_EMAIL = "t2@test.com"

RSpec.feature "users:", type: :feature do
  describe "the profile link in the sidenav", js: true do
    it "links to the user's profile" do
      create_user
      log_in

      find("#profile-widget").hover_and_click
      sleep 0.5
      find("#sidenav a", text: "Profile").click

      expect(page).to have_current_path user_path(User.first)
    end
  end

  describe "/users/:username" do
    before do
      create_user

      TEST_TRAINEES.each do |_, attrs|
        trainee = Trainee.new user: User.first, **attrs
        trainee.save!
      end
    end

    context "if the user does not exist" do
      it "404s" do
        visit "/users/nobodyhome"

        expect(page).to have_content "404"
      end
    end

    context "if the user exists" do
      context "while logged out" do
        before do
          visit "/users/#{TEST_USERNAME}"
        end

        it "doesn't display the email" do
          expect(page).not_to have_field "user_email"
        end

        it "does not have an edit button" do
          expect(page).not_to have_css "#edit-btn"
        end

        ### General tests regarding the page. These also apply while logged in.

        it "displays artwork linking to the user's trainees" do
          User.first.trainees.each do |trainee|
            if trainee.species
              expect(page).to have_xpath("//a[contains(@href,'#{trainee_path trainee}')]" \
                                         "//img[contains(@src,'artwork/#{trainee.species.id}.png')]")
            end
          end
        end

        it "doesn't display none artwork" do
          expect(page).not_to have_xpath "//img[contains(@src,'artwork/none.png')]"
        end
      end

      context "while logged in" do
        before do
          log_in

          visit user_path User.first
        end

        describe "the edit button" do
          it "is disabled" do
            expect(page).to have_css "#edit-btn[disabled]"
          end

          context "when the email is changed", js: true do
            # Running this before the invalid change- that way it changes
            # to a valid input, and then back.
            before do
              fill_in "user_email", with: TEST_CHANGED_EMAIL
            end

            context "to a valid input and pressed" do
              before do
                find("#edit-btn").click
                sleep 0.5
              end

              it "remains on the profile page" do
                expect(page).to have_current_path user_path(User.first)
              end

              it "changes the user's email" do
                expect(User.first.email).to eq TEST_CHANGED_EMAIL
              end

              it "disables the edit button" do
                expect(page).to have_css "#edit-btn[disabled]"
              end
            end

            context "to an invalid input" do
              it "is disabled" do
                fill_in "user_email", with: "notanemail"

                expect(page).to have_css "#edit-btn[disabled]"
              end
            end

            context "back to the original email" do
              it "is disabled" do
                fill_in "user_email", with: TEST_EMAIL

                expect(page).to have_css "#edit-btn[disabled]"
              end
            end
          end
        end
      end
    end
  end
end
