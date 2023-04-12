# frozen_string_literal: true

class Kill < ApplicationRecord
  belongs_to :trainee

  extend ActiveHash::Associations::ActiveRecordExtensions
  belongs_to_active_hash :species, shortcuts: %i[id]
end
