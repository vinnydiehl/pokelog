require "rails_helper"

RSpec.feature "trainees:", type: :feature do
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
      log_in
      visit trainees_path
    end

    context "with no existing trainees" do
      it "shows a greyed out welcome message" do
        expect(page).to have_selector ".grey-text"
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
