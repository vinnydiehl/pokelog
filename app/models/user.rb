# frozen_string_literal: true

class User < ApplicationRecord
  has_many :trainees

  validates_presence_of :username, message: "can't be blank"
  validates_uniqueness_of :username, message: "has already been taken"
  validates_uniqueness_of :google_id, message: "has already been taken"
  validates :username,
    length: { maximum: 20, message: "must be 20 characters or less" }

  validates :email, email: { mode: :strict, message: "is invalid" },
    length: { maximum: 255, message: "must be 255 characters or less" }

  def to_param
    username
  end
end
