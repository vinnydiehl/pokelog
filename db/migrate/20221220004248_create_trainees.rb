class CreateTrainees < ActiveRecord::Migration[7.0]
  def change
    create_enum :nature,
      YAML.load_file("data/natures.yml").keys.map(&:to_s)

    create_table :trainees do |t|
      t.integer :user_id
      t.integer :team_id, null: true
      t.string :species_id
      t.integer :level
      t.boolean :pokerus
      t.hstore :start_stats
      t.hstore :trained_stats
      t.enum :nature, enum_type: "nature"
      t.hstore :evs

      t.timestamps
    end
  end
end

