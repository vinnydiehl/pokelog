require "rails_helper"

RSpec.feature "trainees:", type: :feature do
  describe "/trainees" do
    context "while logged out" do
      it "redirects to /" do
        [trainees_path, new_trainee_path].each do |path|
          visit path
          expect(page).to have_current_path root_path
        end
      end
    end

    context "while logged in" do
      before :each do
        create_user
        log_in

        visit trainees_path
      end

      context "with no existing trainees" do
        it "shows a greyed out welcome message" do
          expect(page).to have_selector ".grey-text"
        end
      end

      context "with existing trainees" do
        before :each do
          @current_user = User.first

          # Create a second test user, and 5 trainee entries for each user
          @other_user = User.new(
            google_id: "000",
            username: "otheruser",
            email: "other@user.com"
          )
          @other_user.save!

          User.all.each do |user|
            5.times { Trainee.new(user: user).save! }
          end

          visit trainees_path
        end

        it "links to the current user's trainees" do
          Trainee.where(user: @current_user).each do |trn|
            expect(page).to have_link href: trainee_path(trn)
          end
        end

        it "doesn't link to the other users' trainees" do
          Trainee.where(user: @other_user).each do |trn|
            expect(page).not_to have_link href: trainee_path(trn)
          end
        end

        describe "the Train button", js: true do
          it "is disabled" do
            expect(page).to have_selector "#train-btn.disabled"
          end

          context "when you check off a trainee" do
            before :each do
              first(".trainee-checkbox").click
            end

            it "is enabled" do
              expect(page).to have_selector "#train-btn:not(.disabled)"
            end

            context "when you uncheck the trainee" do
              it "is disabled again" do
                first(".trainee-checkbox").click
                expect(page).to have_selector "#train-btn.disabled"
              end
            end
          end

          context "when you check off all trainees and press it" do
            before :each do
              all(".trainee-checkbox").each &:click
              find("#train-btn").click
            end

            it "directs to the #show view for all selected trainees" do
              expect(all(".trainee-info").size).to eq Trainee.where(user: @current_user).size
            end
          end
        end
      end

      describe "the + button" do
        before :each do
          find("#new-trainee").click
        end

        it "creates a new trainee" do
          expect(Trainee.all.size).to eq 1
        end

        it "redirects to the #show view for the new trainee" do
          expect(page).to have_current_path trainee_path(Trainee.first.id)
        end
      end
    end
  end
end
