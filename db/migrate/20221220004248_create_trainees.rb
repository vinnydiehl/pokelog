class CreateTrainees < ActiveRecord::Migration[7.0]
  def change
    create_enum :nature,
      YAML.load_file("data/natures.yml").keys
    create_enum :item,
      YAML.load_file("data/items.yml").keys

    create_table :trainees do |t|
      t.belongs_to :user

      t.string :species_id, null: true
      t.string :nickname, null: true
      t.integer :level, null: true
      t.boolean :pokerus, default: false
      t.enum :nature, enum_type: "nature", null: true
      t.enum :item, enum_type: "item", null: true
      t.integer :hp_ev, default: 0
      t.integer :atk_ev, default: 0
      t.integer :def_ev, default: 0
      t.integer :spa_ev, default: 0
      t.integer :spd_ev, default: 0
      t.integer :spe_ev, default: 0

      t.timestamps
    end
  end
end

