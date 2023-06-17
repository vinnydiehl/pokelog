# frozen_string_literal: true

class EnableHStoreExtension < ActiveRecord::Migration[7.0]
  def self.up
    enable_extension "hstore"
  end

  def self.down
    disable_extension "hstore"
  end
end
