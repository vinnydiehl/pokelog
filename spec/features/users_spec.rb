require "rails_helper"

def logged_in?
  !page.has_selector?("#sign-in") && page.has_selector?("#profile-widget")
end

RSpec.feature "users:", type: :feature do
  describe "a brand new user" do
    before :each do
      visit root_path
    end

    it "is not logged in" do
      expect(logged_in?).to be false
    end
  end

  describe ENDPOINT do
    context "with a new user" do
      before :each do
        visit ENDPOINT
      end

      it "redirects to /register if user does not exist", js: true do
        expect(page).to have_current_path register_path, ignore_query: true
      end

      describe "redirect page", js: true do
        it "has the email pre-filled" do
          expect(page).to have_field "email", with: TOKEN_EMAIL
        end

        context "on submission" do
          before :each do
            expect(page).to have_field("username")
            fill_in "username", with: TEST_USERNAME
            fill_in "email", with: TEST_EMAIL
            click_button "Register"

            @user = User.find_by_google_id TEST_G_ID
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

          it "redirects to /" do
            expect(page).to have_current_path root_path
          end

          it "logs the user in" do
            expect(logged_in?).to be true
          end
        end
      end
    end

    context "existing user" do
      before :each do
        log_in
      end

      it "redirects to /" do
        expect(page).to have_current_path root_path
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

  describe "/logout" do
    before :each do
      log_in
      visit ENDPOINT
      visit logout_path
    end

    it "redirects to /" do
      expect(page).to have_current_path root_path
    end

    it "logs the user out" do
      expect(logged_in?).to be false
    end
  end

  describe "/register" do
    it "redirects to / with no POST input" do
      visit register_path
      expect(page).to have_current_path(root_path)
    end
  end
end
