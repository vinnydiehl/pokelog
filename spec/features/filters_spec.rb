# frozen_string_literal: true

require "rails_helper"

QUERY = "b"

# Grab a sample of 5 evenly spread out elements
# to test, otherwise this takes forever
def data_entry_sample
  results = find_all(".data-entry")
  return results if results.length <= 5
  step = results.length / 5
  (0...5).map { |i| results[i * step] }
end

# Spec to see that the query string is being applied
def results_should_contain_query
  it "displays only results containing the query" do
    data_entry_sample.each do |data_entry|
      expect(data_entry.find(".name").text.downcase).to include QUERY
    end
  end
end

# Ticks the check boxes for the specified filters. Must have modal open.
def check_filter(*names)
  names.each do |name|
    find("span", text: name).hover_and_click
  end

  # Refreshing shouldn't be necessary, but Selenium gets upset
  # at the page reload behind the modal.
  sleep 0.5
  refresh
end

# Get types of a .data-entry as symbols
def get_types(data_entry)
  data_entry.find(".types").all(".type").map do |elem|
    elem[:class].gsub(/\s*type\s*/, "").to_sym
  end
end

RSpec.feature "filters:", type: :feature, js: true do
  describe "/trainees/:ids" do
    before do
      launch_new_blank_trainee
    end

    context "when visiting via a URL" do
      before do
        visit trainee_path(Trainee.first) +
          "?q=&filters[yielded][]=hp&filters[min]=2&filters[types][]=normal&filters[weak_to][]=fighting"
        find("#filters-btn").click
      end

      it "has the EVs yielded filter selected" do
        expect(page).to have_checked_field "filters_yielded_hp", visible: :hidden
      end

      it "has the Amount yielded input set" do
        expect(page).to have_checked_field "filters_min", visible: :hidden
      end

      it "has the Types filter selected" do
        expect(page).to have_checked_field "filters_types_normal", visible: :hidden
      end

      it "has the Weak to filter selected" do
        expect(page).to have_checked_field "filters_weak_to_fighting", visible: :hidden
      end
    end

    [["out", false], ["", true]].each do |out, using_query|
      context "with#{out} a query" do
        if using_query
          before do
            fill_in "Search", with: QUERY
          end

          # Tests using a query

          results_should_contain_query
        else
          # Tests not using a query

          context "with no filters selected" do
            it "doesn't show any kill buttons" do
              expect(page).not_to have_selector(".data-entry")
            end
          end

          context "if you try to check more than 2 types filters" do
            before do
              find("#filters-btn").click

              within "#types_filters" do
                %w[Normal Fighting Flying].each do |type|
                  find("span", text: type).click
                end
              end

              sleep 0.5
            end

            it "doesn't let you" do
              expect(find("#filters_types_flying", visible: false).checked?).
                to be false
            end

            it "doesn't send the form" do
              expect(current_url).not_to include "flying"
            end
          end
        end

        # Tests to run both with/without query below here

        describe "amount yielded slider" do
          [1..1, 1..2, 2..3, 3..3].each do |range|
            context "when set #{range}" do
              before do
                visit trainee_path(Trainee.first) +
                  "?q=#{using_query ? QUERY : ''}&filters[min]=#{range.min}&filters[max]=#{range.max}"
              end

              results_should_contain_query if using_query

              it "only displays the species if either yield is in-range" do
                data_entry_sample.each do |data_entry|
                  # Get yields of the data entry as integers
                  yields = data_entry.find(".yields").all(".stat").map do |elem|
                    elem.text.slice(/\d/).to_i
                  end

                  expect(yields).to be_any { |value| range.include?(value) }
                end
              end
            end
          end
        end

        describe "the filters menu" do
          before do
            find("#filters-btn").click
          end

          describe "the Clear All button" do
            before do
              within("#species-filters") { find_all("span").each(&:click) }
              sleep 0.5
              find("#clear-filters-btn").click
              sleep 0.5

              # Refresh not necessary, but tests that the URL has been modified
              refresh
            end

            it "clears all inputs" do
              expect(page).to have_current_path trainee_path(Trainee.first) +
                "?q=#{using_query ? QUERY : ''}"
            end
          end

          # EVs yielded

          PokeLog::Stats.stats.each_with_index do |stat, i|
            context "when you check the #{format_stat stat} filter" do
              before do
                check_filter format_stat(stat)
              end

              it "sets the query string" do
                # Indicates the form was successfully submitted by Stimulus
                expect(page).to have_current_path trainee_path(Trainee.first) +
                  "?q=#{using_query ? QUERY : ''}&filters[yielded][]=#{stat}"
              end

              describe "the results" do
                # Only run these for the first type, to save time
                if i == 1
                  results_should_contain_query if using_query

                  it "are displayed" do
                    expect(page).to have_selector(".data-entry")
                  end
                end

                it "all yield #{format_stat stat} EVs" do
                  data_entry_sample.each do |data_entry|
                    expect(data_entry.find ".yields").to have_css ".#{stat}"
                  end
                end
              end
            end
          end

          context "when you select multiple EVs yielded filters" do
            before do
              @test_filters = %w[HP Atk Def]

              check_filter(*@test_filters)
            end

            it "displays species that yield any of the selected EVs" do
              data_entry_sample.each do |data_entry|
                expect(@test_filters).to be_any do |stat|
                  data_entry.find(".yields").has_css? ".#{stat.downcase}"
                end
              end
            end
          end

          # Types

          PokeLog::Types.types.each_with_index do |type, i|
            context "when you check the type #{type.capitalize} filter" do
              before do
                within "#types_filters" do
                  check_filter type.capitalize
                end
              end

              it "sets the query string" do
                # Indicates the form was successfully submitted by Stimulus
                expect(page).to have_current_path trainee_path(Trainee.first) +
                  "?q=#{using_query ? QUERY : ''}&filters[types][]=#{type}"
              end

              describe "the results" do
                # Only run these for the first type, to save time
                if i == 1
                  results_should_contain_query if using_query

                  it "are displayed" do
                    expect(page).to have_selector(".data-entry")
                  end
                end

                it "are all #{type.capitalize} type" do
                  data_entry_sample.each do |data_entry|
                    expect(data_entry.find ".types").to have_css ".#{type}"
                  end
                end
              end
            end
          end

          context "when you select 2 types filters" do
            before do
              @test_types = %w[Rock Ground]

              within "#types_filters" do
                check_filter(*@test_types)
              end
            end

            it "only shows Pokémon that are both types" do
              data_entry_sample.each do |data_entry|
                @test_types.each do |type|
                  expect(data_entry.find ".types").to have_css ".#{type.downcase}"
                end
              end
            end
          end

          # Weak to

          PokeLog::Types.types.each_with_index do |type, i|
            context "when you check the weak to #{type.capitalize} filter" do
              before do
                within "#weak_to_filters" do
                  check_filter type.capitalize
                end
              end

              it "sets the query string" do
                # Indicates the form was successfully submitted by Stimulus
                expect(page).to have_current_path trainee_path(Trainee.first) +
                  "?q=#{using_query ? QUERY : ''}&filters[weak_to][]=#{type}"
              end

              describe "the results" do
                # Only run these for the first type, to save time
                if i == 1
                  results_should_contain_query if using_query

                  it "are displayed" do
                    expect(page).to have_selector(".data-entry")
                  end
                end

                it "are all weak to #{type.capitalize} type" do
                  data_entry_sample.each do |data_entry|
                    types = get_types data_entry

                    expect(PokeLog::Types.multiplier type, types).to be > 1
                  end
                end
              end
            end
          end

          context "when you select multiple weak_to filters" do
            before do
              @test_types = %w[Fighting Ground Dragon]

              within "#weak_to_filters" do
                check_filter(*@test_types)
              end
            end

            it "displays species that are weak to any of the types" do
              data_entry_sample.each do |data_entry|
                types = get_types data_entry

                expect(@test_types).to be_any do |type|
                  PokeLog::Types.multiplier(type.downcase.to_sym, types) > 1
                end
              end
            end
          end
        end
      end
    end
  end
end
