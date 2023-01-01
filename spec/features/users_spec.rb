require "rails_helper"

ENDPOINT = "/login/submit"

TEST_USERNAME = "testname"
CHANGED_EMAIL = "t@test.com"

RSpec.feature "Users", type: :feature do
  describe ENDPOINT do
    context "new user" do
      before :each do
        visit ENDPOINT
      end

      it "redirects to /register if user does not exist" do
        expect(page).to have_current_path register_path, ignore_query: true
      end

      describe "redirect page" do
        it "has the email pre-filled" do
          expect(page).to have_field "email", with: TEST_EMAIL
        end

        context "on submission" do
          before :each do
            expect(page).to have_field("username")
            fill_in "username", with: TEST_USERNAME
            fill_in "email", with: CHANGED_EMAIL
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
            expect(@user.email).to eq CHANGED_EMAIL
          end

          it "sets the Google ID" do
            expect(@user.google_id).to eq TEST_G_ID
          end

          it "redirects to /" do
            expect(page).to have_current_path root_path
          end

          it "logs the user in" do
            expect(page).to have_selector "#profile-widget"
          end
        end
      end
    end

    context "existing user" do
      before :each do
        User.new(
          google_id: TEST_G_ID,
          username: TEST_USERNAME,
          email: CHANGED_EMAIL
        ).save
        visit ENDPOINT
      end

      it "redirects to /" do
        expect(page).to have_current_path root_path
      end

      it "logs the user in" do
        expect(page).to have_selector "#profile-widget"
      end

      it "remains logged in while browsing" do
        visit species_path
        expect(page).to have_selector "#profile-widget"
      end
    end
  end

  describe "/logout" do
    before :each do
      User.new(
        google_id: TEST_G_ID,
        username: TEST_USERNAME,
        email: CHANGED_EMAIL
      ).save
      visit ENDPOINT
      visit logout_path
    end

    it "redirects to /" do
      expect(page).to have_current_path root_path
    end

    it "logs the user out" do
      expect(page).not_to have_selector "#profile-widget"
    end
  end

  describe "/register" do
    it "redirects to / with no POST input" do
      visit register_path
      expect(page).to have_current_path(root_path)
    end
  end
end
