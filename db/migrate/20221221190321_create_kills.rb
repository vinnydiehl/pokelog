class CreateKills < ActiveRecord::Migration[7.0]
  def change
    create_table :kills, id: false do |t|
      t.integer :trainee_id
      t.string :species_id

      t.timestamps
    end
  end
end
