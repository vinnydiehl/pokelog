# frozen_string_literal: true

require "rails_helper"

# The GSI API is stubbed, this is just to test that
# the credential gets passed around properly
TEST_CREDENTIAL = "testcred"

def logged_in?
  !page.has_selector?("#sign-in") && page.has_selector?("#profile-widget")
end

def use_register_form
  fill_in "username", with: TEST_USERNAME
  fill_in "email", with: TEST_EMAIL
  click_button "Register"
end

RSpec.feature "users:", type: :feature do
  describe "/" do
    context "while logged out" do
      before do
        visit root_path
      end

      it "does not redirect" do
        expect(page).to have_current_path root_path
      end
    end

    context "while logged in" do
      before do
        create_user
        log_in

        visit root_path
      end

      it "redirects to /trainees" do
        expect(page).to have_current_path trainees_path
      end

      %w[/home /index].each do |path|
        context "when visiting #{path}" do
          it "does not redirect" do
            visit path

            expect(page).to have_current_path path
          end
        end
      end
    end
  end

  describe "a brand new user" do
    before do
      visit root_path
    end

    it "is not logged in" do
      expect(logged_in?).to be false
    end
  end

  describe ENDPOINT do
    context "with a new user" do
      before do
        visit "#{ENDPOINT}?credential=#{TEST_CREDENTIAL}"
      end

      it "redirects to /register", js: true do
        expect(page).to have_current_path register_path, ignore_query: true
      end

      describe "/register", js: true do
        it "has the email pre-filled" do
          expect(page).to have_field "email", with: TOKEN_EMAIL
        end

        it "has the Google credential loaded" do
          expect(find("#credential", visible: false).value).to eq TEST_CREDENTIAL
        end

        it "has the register button disabled" do
          expect(page).to have_button "Register", disabled: true
        end

        context "if you put text into the username field" do
          before do
            fill_in "username", with: "-"
          end

          it "enables the register button" do
            expect(page).to have_button "Register", disabled: false
          end

          context "if you delete the entered username" do
            it "disables the register button" do
              fill_in "username", with: ""
              expect(page).to have_button "Register", disabled: true
            end
          end
        end

        describe "the username field" do
          it "doesn't allow you to enter more than 20 characters" do
            fill_in "username", with: "-" * 21
            expect(page).to have_field "username", with: "-" * 20
          end
        end

        context "on submission" do
          context "with a unique username" do
            before do
              use_register_form
              @user = User.find_by google_id: TEST_G_ID
            end

            it "creates a new user" do
              expect(@user).to be_present
            end

            it "sets the username" do
              expect(@user.username).to eq TEST_USERNAME
            end

            it "sets the email" do
              expect(@user.email).to eq TEST_EMAIL
            end

            it "sets the Google ID" do
              expect(@user.google_id).to eq TEST_G_ID
            end

            it "redirects to /trainees" do
              expect(page).to have_current_path trainees_path
            end

            it "logs the user in" do
              expect(logged_in?).to be true
            end

            it "displays a notice" do
              expect(page).to have_selector "#notice"
            end
          end

          context "with a username that is taken" do
            before do
              create_user
              use_register_form
            end

            it "does not create a new user" do
              expect(User.all.size).to eq 1
            end

            it "stays on /register" do
              expect(page).to have_current_path "/register", ignore_query: true
            end

            it "keeps the email pre-filled" do
              expect(page).to have_field "email", with: TOKEN_EMAIL
            end

            it "keeps the Google credential loaded" do
              expect(find("#credential", visible: false).value).to eq TEST_CREDENTIAL
            end

            it "displays a notice" do
              expect(page).to have_selector "#notice"
            end
          end
        end
      end
    end

    context "existing user" do
      before do
        create_user
        log_in
      end

      it "redirects to /trainees" do
        expect(page).to have_current_path trainees_path
      end

      it "logs the user in" do
        expect(logged_in?).to be true
      end

      it "remains logged in while browsing" do
        visit species_path
        expect(logged_in?).to be true
      end
    end
  end

  describe "/logout", js: true do
    before do
      create_user
      log_in

      find("#profile-widget").click
      sleep 0.5
      find("#sidenav a", text: "Logout").click
    end

    it "redirects to /" do
      expect(page).to have_current_path root_path
    end

    it "logs the user out" do
      expect(logged_in?).to be false
    end

    it "displays a notice" do
      expect(page).to have_selector "#notice"
    end
  end

  describe "/register" do
    it "redirects to / with no POST input" do
      visit register_path
      expect(page).to have_current_path(root_path)
    end
  end
end
