require "application_system_test_case"

class TraineesTest < ApplicationSystemTestCase
  setup do
    @trainee = trainees(:one)
  end

  test "visiting the index" do
    visit trainees_url
    assert_selector "h1", text: "Trainees"
  end

  test "should create trainee" do
    visit trainees_url
    click_on "New trainee"

    fill_in "Evs", with: @trainee.evs
    fill_in "Kills", with: @trainee.kills
    fill_in "Level", with: @trainee.level
    fill_in "Nature", with: @trainee.nature
    check "Pokerus" if @trainee.pokerus
    fill_in "Species", with: @trainee.species_id
    fill_in "Start stats", with: @trainee.start_stats
    fill_in "Team", with: @trainee.team_id
    fill_in "Trained stats", with: @trainee.trained_stats
    fill_in "User", with: @trainee.user_id
    click_on "Create Trainee"

    assert_text "Trainee was successfully created"
    click_on "Back"
  end

  test "should update Trainee" do
    visit trainee_url(@trainee)
    click_on "Edit this trainee", match: :first

    fill_in "Evs", with: @trainee.evs
    fill_in "Kills", with: @trainee.kills
    fill_in "Level", with: @trainee.level
    fill_in "Nature", with: @trainee.nature
    check "Pokerus" if @trainee.pokerus
    fill_in "Species", with: @trainee.species_id
    fill_in "Start stats", with: @trainee.start_stats
    fill_in "Team", with: @trainee.team_id
    fill_in "Trained stats", with: @trainee.trained_stats
    fill_in "User", with: @trainee.user_id
    click_on "Update Trainee"

    assert_text "Trainee was successfully updated"
    click_on "Back"
  end

  test "should destroy Trainee" do
    visit trainee_url(@trainee)
    click_on "Destroy this trainee", match: :first

    assert_text "Trainee was successfully destroyed"
  end
end
