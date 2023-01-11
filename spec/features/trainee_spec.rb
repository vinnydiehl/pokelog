require "rails_helper"

RSpec.feature "trainees:", type: :feature do
  describe "/trainees/:id" do
    it "displays the trainee" do
    end

    context "while logged out" do
      it "doesn't allow you to edit the trainee" do
      end
    end

    context "while logged in" do
    end
  end
end
