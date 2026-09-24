class Book < ApplicationRecord
  belongs_to :user

  enum :status, {
    unread: 0,
    reading: 1,
    finished: 2
  }, validate: true

  validates :title, presence: true
end
