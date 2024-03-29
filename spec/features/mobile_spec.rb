# frozen_string_literal: true

require "rails_helper"

class Capybara::Node::Element
  delegate :drag_by, to: :base
end

class Capybara::Selenium::Node
  def drag_by(right_by, down_by)
    driver.browser.action.drag_and_drop_by(native, right_by, down_by).perform
  end
end

def click_nav_link(text)
  find("#sidenav-expand").click
  find("#sidenav div", text:).click
end

RSpec.feature "mobile UI:", type: :feature, driver: :chrome_mobile do
  it "doesn't display the sidenav" do
    expect(page).not_to have_selector "#sidenav"
  end

  describe "the sidenav" do
    before do
      create_user
      log_in
    end

    it "opens reliably while navigating pages" do
      # No expectations here; if it successfully navigates the links, it passes
      ["EV Yields", "Trainees", "About Us"].each { |name| click_nav_link name }
    end

    context "when you click a nav link, then go back" do
      before do
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

  describe "trainees#show" do
    before do
      launch_new_blank_trainee
      fill_in "Search", with: "Caterpie" # 1 HP
    end

    context "when you click a kill button" do
      before do
        find("#species_010").click
      end

      it "does nothing" do
        sleep 0.5

        expect(find("#trainee_hp_ev").value).to be_blank
        expect(Trainee.first.hp_ev).to eq 0
      end

      context "in landscape mode (regular buttons visible)", driver: :chrome_mobile_ls do
        it "increments the EV" do
          wait_for :hp_ev, 1

          expect(find("#trainee_hp_ev").value).to eq "1"
          expect(Trainee.first.hp_ev).to eq 1
        end
      end
    end

    %i[left right].each do |dir|
      context "when you swipe a kill button to the #{dir}" do
        it "increments the EV" do
          find("#species_010 #{dir == :left ? '.yields-and-types' : '.id'}").
            # 100px is dialed in for how quickly the driver swipes. As you
            # decrease sensitivity in the app, just as this test starts to fail,
            # the swiping starts to feel unresponsive.
            drag_by (100 * (dir == :left ? -1 : 1)), 0
          wait_for :hp_ev, 1

          expect(find("#trainee_hp_ev").value).to eq "1"
          expect(Trainee.first.hp_ev).to eq 1
        end
      end
    end
  end
end
