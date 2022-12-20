require "test_helper"

class TraineesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @trainee = trainees(:one)
  end

  test "should get index" do
    get trainees_url
    assert_response :success
  end

  test "should get new" do
    get new_trainee_url
    assert_response :success
  end

  test "should create trainee" do
    assert_difference("Trainee.count") do
      post trainees_url, params: { trainee: { evs: @trainee.evs, kills: @trainee.kills, level: @trainee.level, nature: @trainee.nature, pokerus: @trainee.pokerus, species_id: @trainee.species_id, start_stats: @trainee.start_stats, team_id: @trainee.team_id, trained_stats: @trainee.trained_stats, user_id: @trainee.user_id } }
    end

    assert_redirected_to trainee_url(Trainee.last)
  end

  test "should show trainee" do
    get trainee_url(@trainee)
    assert_response :success
  end

  test "should get edit" do
    get edit_trainee_url(@trainee)
    assert_response :success
  end

  test "should update trainee" do
    patch trainee_url(@trainee), params: { trainee: { evs: @trainee.evs, kills: @trainee.kills, level: @trainee.level, nature: @trainee.nature, pokerus: @trainee.pokerus, species_id: @trainee.species_id, start_stats: @trainee.start_stats, team_id: @trainee.team_id, trained_stats: @trainee.trained_stats, user_id: @trainee.user_id } }
    assert_redirected_to trainee_url(@trainee)
  end

  test "should destroy trainee" do
    assert_difference("Trainee.count", -1) do
      delete trainee_url(@trainee)
    end

    assert_redirected_to trainees_url
  end
end
