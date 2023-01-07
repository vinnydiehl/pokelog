class Trainee < ApplicationRecord
  belongs_to :user
  has_many :kills

  extend ActiveHash::Associations::ActiveRecordExtensions
  belongs_to_active_hash :species, shortcuts: %i[id]
end
