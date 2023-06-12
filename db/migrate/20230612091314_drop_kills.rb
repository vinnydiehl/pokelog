# frozen_string_literal: true

class DropKills < ActiveRecord::Migration[7.0]
  def change
    drop_table :kills do |t|
      t.belongs_to :trainees

      t.string :species_id

      t.timestamps
    end
  end
end
