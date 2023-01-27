class User < ApplicationRecord
  has_many :trainees

  validates_presence_of :username
  validates_uniqueness_of :username
  validates :username, length: 1..20

  validates_presence_of :email
  validates :email, email: true

  def to_param
    username
  end
end
