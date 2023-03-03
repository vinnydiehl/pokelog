class AddGoalsToTrainees < ActiveRecord::Migration[7.0]
  def change
    %i[hp_goal atk_goal def_goal spa_goal spd_goal spe_goal].each do |name|
      add_column :trainees, name, :integer, default: 0
    end
  end
end
