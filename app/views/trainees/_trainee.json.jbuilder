json.extract! trainee, :id, :user_id, :team_id, :species_id, :level, :pokerus, :start_stats, :trained_stats, :kills, :nature, :evs, :created_at, :updated_at
json.url trainee_url(trainee, format: :json)
