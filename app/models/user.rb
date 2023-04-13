# frozen_string_literal: true

class User < ApplicationRecord
  has_many :trainees

  validates :username, presence: { message: "can't be blank" },
                     uniqueness: { message: "has already been taken" },
                         length: { maximum: 20, message: "must be 20 characters or less" }

  validates :google_id, uniqueness: { message: "has already been taken" }

  validates :email, email: { mode: :strict, message: "is invalid" },
                   length: { maximum: 255, message: "must be 255 characters or less" }

  def to_param
    username
  end
end
