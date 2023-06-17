# frozen_string_literal: true

class AddUniqueIndexes < ActiveRecord::Migration[7.0]
  def change
    %i[username google_id].each { |f| add_index :users, f, unique: true }
  end
end
