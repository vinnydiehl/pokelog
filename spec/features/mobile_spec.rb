require "rails_helper"

def click_nav_link(text)
  find("#sidenav-expand").click
  find("#sidenav div", text: text).click
end

RSpec.feature "mobile UI:", type: :feature, driver: :chrome_375 do
  it "doesn't display the sidenav" do
    expect(page).not_to have_selector "#sidenav"
  end

  describe "the sidenav" do
    before :each do
      create_user
      log_in
    end

    it "opens reliably while navigating pages" do
      # No expectations here; if it successfully navigates the links, it passes
      ["EV Yields", "Trainees", "About Us"].each { |name| click_nav_link name }
    end

    context "when you click a nav link, then go back" do
      before :each do
        click_nav_link "About Us"
        page.go_back
        sleep 0.5
      end

      it "does not display the sidenav or overlay" do
        %w[#sidenav .sidenav-overlay].each do |selector|
          expect(page).not_to have_selector selector
        end
      end

      it "allows the sidenav to be opened again" do
        find("#sidenav-expand").click
        expect(page).to have_selector "#sidenav"
      end
    end
  end
end
