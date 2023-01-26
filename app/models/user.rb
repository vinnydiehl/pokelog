class User < ApplicationRecord
  has_many :trainees

  validates :username, length: 1..20
  validates_uniqueness_of :username
end
